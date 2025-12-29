//
//  CalendarProgramView.swift
//  Workout Tracker
//
//  Created by Justin Tiano on 12/28/25.
//

import SwiftUI

struct CalendarProgramView: View {
    @EnvironmentObject private var store: Store
    @State private var displayedMonth: Date = Calendar.current.startOfDay(for: Date())
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                header
                calendarGrid
                legend
            }
            .padding()
            .background(AppTheme.screenBackground)
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .onAppear {
            // Default view: the month containing program start date if available
            if let s = store.state.startDate {
                displayedMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: s)) ?? displayedMonth
            } else {
                displayedMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? displayedMonth
            }
        }
    }

    private var header: some View {
        let cal = Calendar.current
        let monthTitle = displayedMonth.formatted(.dateTime.month(.wide).year())

        return HStack {
            Button {
                displayedMonth = cal.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.left")
                    .padding(6)
                    .background(AppTheme.surfaceElevated)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text(monthTitle)
                .font(.headline)

            Spacer()

            Button {
                displayedMonth = cal.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.right")
                    .padding(6)
                    .background(AppTheme.surfaceElevated)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
    }

    private var calendarGrid: some View {
        let cal = Calendar.current
        let preset = store.state.profile?.preset ?? .custom
        let startDate = store.state.startDate

        let firstOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: displayedMonth)) ?? displayedMonth
        let range = cal.range(of: .day, in: .month, for: firstOfMonth) ?? 1..<2

        // Calendar.component(.weekday): Sunday=1, Monday=2, ...
        // Convert to Monday=0, Tuesday=1, ..., Sunday=6
        let firstWeekday = cal.component(.weekday, from: firstOfMonth)
        let leadingBlanks = (firstWeekday - 2 + 7) % 7

        let days: [Int?] = Array(repeating: nil, count: leadingBlanks) + range.map { Optional($0) }
        let rows = Int(ceil(Double(days.count) / 7.0))

        return VStack(spacing: 10) {
            HStack {
                ForEach(["M","T","W","T","F","S","S"], id: \.self) { d in
                    Text(d)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<7, id: \.self) { col in
                        let idx = row * 7 + col
                        let dayNum = idx < days.count ? days[idx] : nil

                        Group {
                            if let dayNum {
                                let date = cal.date(bySetting: .day, value: dayNum, of: firstOfMonth) ?? firstOfMonth
                                CalendarDayCell(date: date, startDate: startDate, preset: preset)
                            } else {
                                Color.clear.frame(height: 38)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground(.softBlue))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var legend: some View {
        HStack(spacing: 12) {
            legendDot(color: AppTheme.calendarComplete, label: "Complete")
            legendDot(color: AppTheme.calendarIncomplete, label: "Today")
            legendDot(color: AppTheme.calendarMissed, label: "Missed")
            legendDot(color: AppTheme.sage.opacity(0.35), label: "Upcoming")
            Spacer()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label)
        }
    }
}

struct CalendarDayCell: View {
    @EnvironmentObject private var store: Store

    let date: Date
    let startDate: Date?
    let preset: Preset

    var body: some View {
        let cal = Calendar.current
        let cellDay = cal.component(.day, from: date)
        let state = dayState(today: cal.startOfDay(for: Date()))

        return NavigationLink {
            if let dest = destination() {
                dest
            } else {
                Text("Not in program range")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.calendarDayFill(state))
                    .background(AppTheme.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(strokeColor(for: state).opacity(0.55), lineWidth: 1)
                    )

                Text("\(cellDay)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(foregroundColor(for: state))
            }
            .frame(height: 38)
        }
        .buttonStyle(.plain)
    }

    private func destination() -> AnyView? {
        guard let startDate else { return nil }
        guard let idx = WorkoutProgress.indexFor(startDate: startDate, date: date) else { return nil }
        let weekNumber = idx.weekIndex + 1
        let day = DayOfWeek.allCases[idx.dayIndex]
        return AnyView(DayDetailView(weekNumber: weekNumber, day: day, date: date))
    }

    private func dayState(today: Date) -> CalendarDayState {
        let cal = Calendar.current
        let d0 = cal.startOfDay(for: date)

        // Always highlight the real-world "today" date.
        if d0 == today {
            // If it's within the program range and complete, show complete.
            if let startDate,
               let idx = WorkoutProgress.indexFor(startDate: startDate, date: date) {
                let week = store.state.weeks[idx.weekIndex]
                let day = DayOfWeek.allCases[idx.dayIndex]
                let log = week.days[idx.dayIndex]
                let complete = WorkoutProgress.isDayComplete(weekNumber: week.weekNumber, day: day, dayLog: log, preset: preset)
                return complete ? .complete : .incomplete
            }

            // Otherwise, still show as "today".
            return .incomplete
        }

        // If we don't have a start date yet, everything else is upcoming.
        guard let startDate else {
            return .upcoming
        }

        // If the date is not within the program range, don't mark as missed—just show upcoming.
        guard let idx = WorkoutProgress.indexFor(startDate: startDate, date: date) else {
            return .upcoming
        }

        let week = store.state.weeks[idx.weekIndex]
        let day = DayOfWeek.allCases[idx.dayIndex]
        let log = week.days[idx.dayIndex]

        let complete = WorkoutProgress.isDayComplete(weekNumber: week.weekNumber, day: day, dayLog: log, preset: preset)
        if complete { return .complete }

        if d0 < today { return .missed }
        return .upcoming
    }

    private func strokeColor(for state: CalendarDayState) -> Color {
        switch state {
        case .complete:
            return AppTheme.calendarComplete
        case .incomplete:
            return AppTheme.calendarIncomplete
        case .missed:
            return AppTheme.calendarMissed
        case .upcoming:
            return AppTheme.sage
        }
    }

    private func foregroundColor(for state: CalendarDayState) -> Color {
        switch state {
        case .upcoming:
            return AppTheme.ink
        default:
            return AppTheme.ink
        }
    }
}

struct DayDetailView: View {
    @EnvironmentObject private var store: Store

    let weekNumber: Int
    let day: DayOfWeek
    let date: Date

    var body: some View {
        let preset = store.state.profile?.preset ?? .custom

        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today")
                        .font(.headline)
                    DayCard(weekNumber: weekNumber, day: day, preset: preset)
                }
                .padding()
                .background(AppTheme.cardBackground(.softCoral))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .background(AppTheme.screenBackground)
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CalendarProgramView()
        .environmentObject(Store())
}
