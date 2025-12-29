
import SwiftUI
import WebKit

struct WorkoutSessionView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss

    @State private var selection: Int = 0
    @State private var didInitializeSelection = false

    // Timer state (per-exercise page)
    @State private var isTimerRunning = false
    @State private var remainingSeconds: Int = 0
    @State private var timerTotalSeconds: Int = 0

    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            AppTheme.screenBackground.ignoresSafeArea()

            if let ctx = todayContext {
                sessionView(ctx)
            } else {
                emptyState
            }
        }
        .onReceive(tick) { _ in
            guard isTimerRunning, remainingSeconds > 0 else { return }
            remainingSeconds -= 1
            if remainingSeconds == 0 { isTimerRunning = false }
        }
    }

    // MARK: - Main Session

    @ViewBuilder
    private func sessionView(_ ctx: TodayContext) -> some View {
        let exercises = ctx.exercises

        VStack(spacing: 0) {
            topBar(ctx: ctx)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 6)

            TabView(selection: $selection) {
                ForEach(exercises.indices, id: \.self) { i in
                    ExercisePage(
                        exercise: exercises[i],
                        isComplete: ctx.dayLog.exerciseDone[exercises[i].id] == true,
                        onToggleComplete: {
                            markComplete(ctx: ctx, exerciseID: exercises[i].id)
                            advance(from: i, in: exercises, ctx: ctx)
                        },
                        timerInfo: timerInfo(for: exercises[i]),
                        isTimerRunning: $isTimerRunning,
                        remainingSeconds: $remainingSeconds,
                        timerTotalSeconds: $timerTotalSeconds
                    )
                    .tag(i)
                }

                CelebrationPage { dismiss() }
                    .tag(exercises.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selection)
            .onAppear { initializeSelectionIfNeeded(ctx: ctx) }
            .onChange(of: selection) { _, newValue in
                guard newValue < exercises.count else {
                    stopAndClearTimer()
                    return
                }
                configureTimerForCurrentExercise(exercises[newValue])
            }
        }
        .onAppear {
            if selection < exercises.count {
                configureTimerForCurrentExercise(exercises[selection])
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)

            Text("No workout available")
                .font(.title3.weight(.semibold))

            Text("Finish setup (name + start date) to begin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Close") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Top Bar

    private func topBar(ctx: TodayContext) -> some View {
        let completed = WorkoutProgress.isDayComplete(
            weekNumber: ctx.week.weekNumber,
            day: ctx.day,
            dayLog: ctx.dayLog,
            preset: ctx.preset
        )

        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today").font(.headline)
                Text("Week \(ctx.week.weekNumber) • \(dayLabel(ctx.day))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(completed ? "Complete" : "In Progress")
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background((completed ? AppTheme.success : AppTheme.calendarIncomplete).opacity(0.18))
                .clipShape(Capsule())

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .padding(10)
                    .background(AppTheme.surfaceElevated)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private func dayLabel(_ day: DayOfWeek) -> String {
        switch day {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }

    // MARK: - Context

    private struct TodayContext {
        let weekIndex: Int
        let dayIndex: Int
        let week: WeekPlan
        let day: DayOfWeek
        let dayLog: DayLog
        let preset: Preset
        let exercises: [Exercise]
    }

    private var todayContext: TodayContext? {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        guard let startDate = store.state.startDate,
              let profile = store.state.profile,
              let idx = WorkoutProgress.indexFor(startDate: startDate, date: today)
        else { return nil }

        guard idx.weekIndex >= 0, idx.weekIndex < store.state.weeks.count else { return nil }
        let week = store.state.weeks[idx.weekIndex]

        guard idx.dayIndex >= 0, idx.dayIndex < week.days.count else { return nil }
        let dayLog = week.days[idx.dayIndex]

        let day = DayOfWeek.allCases[idx.dayIndex]
        let preset = profile.preset

        let exercises = WorkoutLibrary.workoutExercises(for: day, preset: preset)

        return TodayContext(
            weekIndex: idx.weekIndex,
            dayIndex: idx.dayIndex,
            week: week,
            day: day,
            dayLog: dayLog,
            preset: preset,
            exercises: exercises
        )
    }

    // MARK: - Completion + Navigation

    private func initializeSelectionIfNeeded(ctx: TodayContext) {
        guard !didInitializeSelection else { return }
        didInitializeSelection = true

        if let firstIncomplete = ctx.exercises.firstIndex(where: { ctx.dayLog.exerciseDone[$0.id] != true }) {
            selection = firstIncomplete
        } else {
            selection = ctx.exercises.count
        }

        if selection < ctx.exercises.count {
            configureTimerForCurrentExercise(ctx.exercises[selection])
        }
    }

    private func markComplete(ctx: TodayContext, exerciseID: String) {
        var week = store.state.weeks[ctx.weekIndex]
        var log = week.days[ctx.dayIndex]
        log.exerciseDone[exerciseID] = true
        week.days[ctx.dayIndex] = log
        store.state.weeks[ctx.weekIndex] = week
    }

    private func advance(from currentIndex: Int, in exercises: [Exercise], ctx: TodayContext) {
        if let next = (currentIndex + 1 ..< exercises.count).first(where: { i in
            let id = exercises[i].id
            return store.state.weeks[ctx.weekIndex].days[ctx.dayIndex].exerciseDone[id] != true
        }) {
            selection = next
            return
        }

        if let any = (0 ..< exercises.count).first(where: { i in
            let id = exercises[i].id
            return store.state.weeks[ctx.weekIndex].days[ctx.dayIndex].exerciseDone[id] != true
        }) {
            selection = any
            return
        }

        selection = exercises.count
    }

    // MARK: - Timer

    fileprivate struct TimerInfo {
        let totalSeconds: Int
        let label: String
    }

    private func timerInfo(for exercise: Exercise) -> TimerInfo? {
        let text = (exercise.prescription + " " + exercise.recommended).lowercased()

        if let match = text.firstMatch(of: #/(\b\d{1,2})\s*:\s*(\d{2})\b/#) {
            let m = Int(match.1) ?? 0
            let s = Int(match.2) ?? 0
            let total = (m * 60) + s
            if total > 0 { return TimerInfo(totalSeconds: total, label: "Timer") }
        }

        if let match = text.firstMatch(of: #/(\b\d{1,3})\s*(min|mins|minute|minutes)\b/#) {
            let mins = Int(match.1) ?? 0
            let total = mins * 60
            if total > 0 { return TimerInfo(totalSeconds: total, label: "Timer") }
        }

        if let match = text.firstMatch(of: #/(\b\d{1,4})\s*(sec|secs|second|seconds)\b/#) {
            let secs = Int(match.1) ?? 0
            if secs > 0 { return TimerInfo(totalSeconds: secs, label: "Timer") }
        }

        return nil
    }

    private func configureTimerForCurrentExercise(_ exercise: Exercise) {
        stopAndClearTimer()
        guard let info = timerInfo(for: exercise) else { return }
        timerTotalSeconds = info.totalSeconds
        remainingSeconds = info.totalSeconds
    }

    private func stopAndClearTimer() {
        isTimerRunning = false
        remainingSeconds = 0
        timerTotalSeconds = 0
    }
}

// MARK: - Exercise Page

private struct ExercisePage: View {
    let exercise: Exercise
    let isComplete: Bool
    let onToggleComplete: () -> Void

    let timerInfo: WorkoutSessionView.TimerInfo?
    @Binding var isTimerRunning: Bool
    @Binding var remainingSeconds: Int
    @Binding var timerTotalSeconds: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header

                if !exercise.detail.isEmpty {
                    Text(exercise.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                detailsCard

                if let video = WorkoutVideos.youtubeVideo(for: exercise.id) {
                    embeddedVideoCard(video)
                }

                if let timerInfo {
                    timerCard(timerInfo)
                }

                actionRow
                Spacer(minLength: 30)
            }
            .padding()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.title)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.ink)

            HStack {
                Spacer()
                Text(isComplete ? "Done" : "Not done")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background((isComplete ? AppTheme.success : AppTheme.calendarIncomplete).opacity(0.18))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(AppTheme.cardBackground(.softCoral))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Details")
                .font(.headline)

            if !exercise.prescription.isEmpty {
                HStack {
                    Text("Target").foregroundStyle(.secondary)
                    Spacer()
                    Text(exercise.prescription).fontWeight(.semibold)
                }
            }

            if !exercise.recommended.isEmpty {
                HStack {
                    Text("Suggested").foregroundStyle(.secondary)
                    Spacer()
                    Text(exercise.recommended).fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground(.softBlue))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func embeddedVideoCard(_ video: WorkoutVideos.YouTubeVideo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Demo")
                    .font(.headline)
                Spacer()
                Link(destination: video.url) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.rectangle.fill")
                        Text("Open in YouTube")
                    }
                    .font(.caption.bold())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }

            YouTubeEmbedView(url: video.embedURL)
                .frame(height: 210)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.sage.opacity(0.25), lineWidth: 1)
                )

            Text(video.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
        }
        .padding()
        .background(AppTheme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    @ViewBuilder
    private func timerCard(_ info: WorkoutSessionView.TimerInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Timer").font(.headline)
                Spacer()
                Text(formatTime(remainingSeconds == 0 ? info.totalSeconds : remainingSeconds))
                    .font(.headline.monospacedDigit())
            }

            ProgressView(value: progress(total: info.totalSeconds))
                .tint(AppTheme.sage)

            HStack(spacing: 10) {
                Button {
                    if remainingSeconds == 0 { remainingSeconds = info.totalSeconds }
                    isTimerRunning.toggle()
                } label: {
                    Label(isTimerRunning ? "Pause" : "Start",
                          systemImage: isTimerRunning ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    isTimerRunning = false
                    remainingSeconds = info.totalSeconds
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(AppTheme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.sage.opacity(0.35), lineWidth: 1)
        )
    }

    private var actionRow: some View {
        Button {
            onToggleComplete()
        } label: {
            HStack {
                Spacer()
                Image(systemName: isComplete ? "checkmark.circle.fill" : "checkmark.circle")
                Text(isComplete ? "Completed" : "Mark Complete")
                Spacer()
            }
            .font(.headline)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
    }

    private func progress(total: Int) -> Double {
        guard total > 0 else { return 0 }
        let rem = remainingSeconds == 0 ? total : remainingSeconds
        return 1.0 - (Double(rem) / Double(total))
    }

    private func formatTime(_ seconds: Int) -> String {
        let s = max(0, seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

// MARK: - YouTube Embed

private struct YouTubeEmbedView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        let wv = WKWebView(frame: .zero, configuration: cfg)
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.scrollView.isScrollEnabled = false
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

// MARK: - Celebration

private struct CelebrationPage: View {
    let onDismiss: () -> Void
    @State private var didAutoDismiss = false

    var body: some View {
        VStack(spacing: 14) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.success.opacity(0.18))
                    .frame(width: 140, height: 140)

                Image(systemName: "checkmark")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(AppTheme.success)
            }

            Text("Workout Complete")
                .font(.title.bold())

            Text("Tap anywhere to return.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { onDismiss() }
        .onAppear {
            guard !didAutoDismiss else { return }
            didAutoDismiss = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { onDismiss() }
        }
        .padding()
        .background(AppTheme.screenBackground)
    }
}
