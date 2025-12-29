//
//  DashboardView.swift
//  Workout Tracker
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: Store

    @State private var showSettings = false
    @State private var showCalendar = false
    @State private var showWorkoutSession = false
    @State private var showMondayCheckIn = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 16) {

                    if isMonday {
                        MondayCheckInCard {
                            showMondayCheckIn = true
                        }
                    }

                    TodayCard(
                        title: todayTitle,
                        subtitle: todaySubtitle,
                        isComplete: todayIsComplete,
                        onStart: { showWorkoutSession = true },
                        onOpenCalendar: { showCalendar = true }
                    )

                    if let stats = statsContext {
                        CurrentStatsCard(stats: stats)
                    }
                }
                .padding()
            }
            .background(AppTheme.screenBackground)
            .navigationBarItems(trailing: HStack {
                Button {
                    showCalendar = true
                } label: {
                    Image(systemName: "calendar")
                }

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            })
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showCalendar) {
                NavigationStack {
                    CalendarProgramView()
                        .environmentObject(store)
                        .navigationTitle("Calendar")
                        .navigationBarItems(trailing:
                            Button("Done") {
                                showCalendar = false
                            }
                        )
                }
            }
            .sheet(isPresented: $showMondayCheckIn) {
                NavigationStack {
                    // ✅ FIX: CheckInEditor requires weekNumber
                    CheckInEditor(weekNumber: checkInWeekNumber)
                        .environmentObject(store)
                        .navigationTitle("Monday Check-In")
                        .navigationBarItems(trailing:
                            Button("Done") {
                                showMondayCheckIn = false
                            }
                        )
                }
            }
            .fullScreenCover(isPresented: $showWorkoutSession) {
                WorkoutSessionView()
                    .environmentObject(store)
            }
        }
    }

    // ✅ What week should the Monday check-in edit?
    private var checkInWeekNumber: Int {
        // Prefer the current week based on today's date; fallback to last week in state.
        if let ctx = todayContext { return ctx.weekNumber }
        return store.state.weeks.last?.weekNumber ?? 1
    }

    // MARK: - Today Helpers

    private var isMonday: Bool {
        Calendar.current.component(.weekday, from: Date()) == 2
    }

    private var todayTitle: String {
        guard let ctx = todayContext else { return "Today" }
        return "Week \(ctx.weekNumber) • \(ctx.dayLabel)"
    }

    private var todaySubtitle: String {
        guard todayContext != nil else {
            return "Finish setup to begin your program."
        }
        return todayIsComplete
            ? "Nice — you finished today."
            : "You’ve got this. Start when ready."
    }

    private var todayIsComplete: Bool {
        guard let ctx = todayContext else { return false }
        return ctx.exercises.allSatisfy { ctx.dayLog.exerciseDone[$0.id] == true }
    }

    // MARK: - Stats Overview (appears after Week 1 check-in)

    private struct StatsContext {
        let baselineWeek: Int
        let currentWeek: Int
        let baseline: CheckIn
        let current: CheckIn
    }

    private var statsContext: StatsContext? {
        guard !store.state.weeks.isEmpty else { return nil }

        // Need a Week 1 baseline before showing comparisons
        let baseline = store.state.weeks[0].checkIn
        guard baseline.isEmpty == false else { return nil }

        // Current = latest non-empty check-in (or baseline if only week 1 exists)
        guard let latestIdx = store.state.weeks.lastIndex(where: { $0.checkIn.isEmpty == false }) else {
            return nil
        }

        let currentWeek = store.state.weeks[latestIdx].weekNumber
        let current = store.state.weeks[latestIdx].checkIn

        return StatsContext(
            baselineWeek: 1,
            currentWeek: currentWeek,
            baseline: baseline,
            current: current
        )
    }

    private func fmt(_ v: Double?) -> String {
        guard let v else { return "—" }
        if v.rounded() == v { return String(Int(v)) }
        return String(v)
    }

    private func fmt(_ v: Int?) -> String {
        guard let v else { return "—" }
        return String(v)
    }

    private struct TodayContext {
        let weekNumber: Int
        let dayLabel: String
        let dayLog: DayLog
        let exercises: [Exercise]
    }

    private var todayContext: TodayContext? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard
            let startDate = store.state.startDate,
            let profile = store.state.profile,
            let index = WorkoutProgress.indexFor(startDate: startDate, date: today)
        else {
            return nil
        }

        let week = store.state.weeks[index.weekIndex]
        let dayLog = week.days[index.dayIndex]

        let dayEnum = DayOfWeek.allCases[index.dayIndex]
        let exercises = WorkoutLibrary.workoutExercises(
            for: dayEnum,
            preset: profile.preset
        )

        return TodayContext(
            weekNumber: week.weekNumber,
            dayLabel: dayLabel(for: index.dayIndex),
            dayLog: dayLog,
            exercises: exercises
        )
    }

    private func dayLabel(for index: Int) -> String {
        switch index {
        case 0: return "Monday"
        case 1: return "Tuesday"
        case 2: return "Wednesday"
        case 3: return "Thursday"
        case 4: return "Friday"
        case 5: return "Saturday"
        default: return "Sunday"
        }
    }
}

// MARK: - Cards

private struct MondayCheckInCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppTheme.sage)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Monday Check-In")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)

                    Text("Update your stats for the week.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(AppTheme.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}

private struct TodayCard: View {
    let title: String
    let subtitle: String
    let isComplete: Bool
    let onStart: () -> Void
    let onOpenCalendar: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.ink)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Circle()
                    .fill((isComplete ? AppTheme.success : AppTheme.calendarIncomplete).opacity(0.25))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: isComplete ? "checkmark" : "circle")
                            .foregroundStyle(isComplete ? AppTheme.success : .secondary)
                    )
            }

            HStack(spacing: 10) {
                Button(action: onStart) {
                    Label(
                        isComplete ? "Review Workout" : "Start Workout",
                        systemImage: "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)

                Button(action: onOpenCalendar) {
                    Label("Calendar", systemImage: "calendar")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(AppTheme.cardBackground(.softBlue))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct CurrentStatsCard: View {
    let stats: DashboardView.StatsContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current Stats")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Text("Week \(stats.currentWeek) vs Week \(stats.baselineWeek)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            StatRow(
                title: "Weight (lb)",
                current: format(stats.current.weightLbs),
                delta: delta(stats.current.weightLbs, stats.baseline.weightLbs),
                betterWhen: .down
            )
            StatRow(
                title: "Waist (in)",
                current: format(stats.current.waistIn),
                delta: delta(stats.current.waistIn, stats.baseline.waistIn),
                betterWhen: .down
            )
            StatRow(
                title: "Hips (in)",
                current: format(stats.current.hipsIn),
                delta: delta(stats.current.hipsIn, stats.baseline.hipsIn),
                betterWhen: .down
            )
            StatRow(
                title: "Arm (in)",
                current: format(stats.current.armIn),
                delta: delta(stats.current.armIn, stats.baseline.armIn),
                betterWhen: .down
            )
            StatRow(
                title: "Thigh (in)",
                current: format(stats.current.thighIn),
                delta: delta(stats.current.thighIn, stats.baseline.thighIn),
                betterWhen: .down
            )
            StatRow(
                title: "Resting HR",
                current: format(stats.current.restingHR),
                delta: delta(stats.current.restingHR, stats.baseline.restingHR),
                betterWhen: .down
            )
            StatRow(
                title: "Avg Steps/day",
                current: format(stats.current.avgDailySteps),
                delta: delta(stats.current.avgDailySteps, stats.baseline.avgDailySteps),
                betterWhen: .up
            )
            StatRow(
                title: "Sleep Score",
                current: format(stats.current.sleepScore),
                delta: delta(stats.current.sleepScore, stats.baseline.sleepScore),
                betterWhen: .up
            )
        }
        .padding()
        .background(AppTheme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private enum BetterWhen {
        case down
        case up
    }

    private struct StatRow: View {
        let title: String
        let current: String
        let delta: Double?
        let betterWhen: BetterWhen

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                    Text(current)
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                }

                Spacer()

                Text(deltaLabel)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(badgeColor.opacity(0.20))
                    .foregroundStyle(badgeColor)
                    .clipShape(Capsule())
            }
        }

        private var deltaLabel: String {
            guard let delta else { return "—" }
            if abs(delta) < 0.000001 { return "0" }
            if delta.rounded() == delta {
                let i = Int(delta)
                return i > 0 ? "+\(i)" : "\(i)"
            }
            return delta > 0 ? "+\(delta)" : "\(delta)"
        }

        private var badgeColor: Color {
            guard let delta else { return .gray }
            if abs(delta) < 0.000001 { return .gray }

            let good: Bool
            switch betterWhen {
            case .down:
                good = delta < 0
            case .up:
                good = delta > 0
            }

            return good ? AppTheme.success : AppTheme.warning
        }
    }

    private func delta(_ a: Double?, _ b: Double?) -> Double? {
        guard let a, let b else { return nil }
        return a - b
    }

    private func delta(_ a: Int?, _ b: Int?) -> Double? {
        guard let a, let b else { return nil }
        return Double(a - b)
    }

    private func format(_ v: Double?) -> String {
        guard let v else { return "—" }
        if v.rounded() == v { return String(Int(v)) }
        return String(v)
    }

    private func format(_ v: Int?) -> String {
        guard let v else { return "—" }
        return String(v)
    }
}
