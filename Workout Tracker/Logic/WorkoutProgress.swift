//
//  WorkoutProgress.swift
//  Workout Tracker
//
//  Created by Justin Tiano on 12/28/25.
//

import Foundation

/// Centralized logic for mapping real calendar dates to program weeks/days
/// and determining completion status.
enum WorkoutProgress {

    // MARK: - Date → Program Index

    /// Returns the week/day index for a given calendar date.
    /// `startDate` is Week 1 Day 1 (diffDays == 0).
    static func indexFor(startDate: Date, date: Date) -> (weekIndex: Int, dayIndex: Int)? {
        let cal = Calendar.current
        let s0 = cal.startOfDay(for: startDate)
        let d0 = cal.startOfDay(for: date)

        guard let diffDays = cal.dateComponents([.day], from: s0, to: d0).day else {
            return nil
        }

        // 12 weeks * 7 days = 84 days
        guard diffDays >= 0 && diffDays < 84 else {
            return nil
        }

        return (diffDays / 7, diffDays % 7)
    }

    /// Converts a program week/day back into a real calendar date.
    static func dateFor(startDate: Date, weekNumber: Int, day: DayOfWeek) -> Date {
        let cal = Calendar.current
        let start = cal.startOfDay(for: startDate)

        let weekOffset = max(0, weekNumber - 1)
        let dayOffset = DayOfWeek.allCases.firstIndex(of: day) ?? 0

        let totalDays = weekOffset * 7 + dayOffset
        return cal.date(byAdding: .day, value: totalDays, to: start) ?? start
    }

    // MARK: - Completion Logic

    static func isDayComplete(
        weekNumber: Int,
        day: DayOfWeek,
        dayLog: DayLog,
        preset: Preset
    ) -> Bool {
        let exercises = WorkoutLibrary.workoutExercises(for: day, preset: preset)
        let required = exercises.filter { !$0.isOptional }

        guard !required.isEmpty else { return false }

        for ex in required {
            if dayLog.exerciseDone[ex.id] != true {
                return false
            }
        }
        return true
    }

    static func completedDays(in week: WeekPlan, preset: Preset) -> Int {
        week.days.enumerated().filter { idx, log in
            let day = DayOfWeek.allCases[idx]
            return isDayComplete(
                weekNumber: week.weekNumber,
                day: day,
                dayLog: log,
                preset: preset
            )
        }.count
    }
}
