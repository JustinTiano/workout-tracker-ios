//
//  Models.swift
//  Workout Tracker
//
//  Created by Justin Tiano on 12/28/25.
//

import Foundation

// MARK: - Preset

enum Preset: String, Codable, CaseIterable {
    case justin = "Justin"
    case melissa = "Melissa"
    case custom = "Custom"
}

// MARK: - User Profile

struct UserProfile: Codable {
    var displayName: String
    var preset: Preset
}

// MARK: - Day Of Week

enum DayOfWeek: String, Codable, CaseIterable, Identifiable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"

    var id: String { rawValue }

    /// Human-friendly label.
    var displayName: String { rawValue }
}

// MARK: - Exercise

struct Exercise: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let prescription: String          // e.g. "3×8–10" or "30–45 min"
    let recommended: String           // e.g. "10 lb/hand"
    let isOptional: Bool

    // UI compatibility
    var title: String { name }

    /// Short description for list rows (no forced decimals anywhere).
    var detail: String {
        var parts: [String] = []
        if !prescription.isEmpty { parts.append(prescription) }
        if !recommended.isEmpty { parts.append(recommended) }
        if isOptional { parts.append("Optional") }
        return parts.joined(separator: " • ")
    }
}

// MARK: - Check-In

struct CheckIn: Codable {
    var weightLbs: Double? = nil
    var waistIn: Double? = nil
    var hipsIn: Double? = nil
    var armIn: Double? = nil
    var thighIn: Double? = nil

    var restingHR: Int? = nil
    var avgDailySteps: Int? = nil
    var sleepScore: Int? = nil

    var notes: String = ""

    var isEmpty: Bool {
        weightLbs == nil && waistIn == nil && hipsIn == nil && armIn == nil && thighIn == nil &&
        restingHR == nil && avgDailySteps == nil && sleepScore == nil &&
        notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Day Log

struct DayLog: Codable {
    /// Map of exercise.id → completed
    var exerciseDone: [String: Bool] = [:]
    var notes: String = ""

    /// Backed by `exerciseDone` so we don’t change persisted schema.
    var completedExerciseIDs: [String] {
        get { exerciseDone.compactMap { $0.value ? $0.key : nil } }
        set {
            var map: [String: Bool] = [:]
            for id in newValue { map[id] = true }
            exerciseDone = map
        }
    }

    func isComplete(_ exerciseID: String) -> Bool {
        exerciseDone[exerciseID] == true
    }
}

// MARK: - Week Plan

struct WeekPlan: Identifiable, Codable {
    var id: UUID = UUID()
    let weekNumber: Int
    var days: [DayLog]
    var checkIn: CheckIn

    init(weekNumber: Int) {
        self.weekNumber = weekNumber
        self.days = Array(repeating: DayLog(), count: DayOfWeek.allCases.count)
        self.checkIn = CheckIn()
    }
}

// MARK: - App State

struct AppState: Codable {
    var profile: UserProfile? = nil
    var startDate: Date? = nil
    var weeks: [WeekPlan] = []

    static func freshProgram(weeks count: Int = 12) -> [WeekPlan] {
        (1...count).map { WeekPlan(weekNumber: $0) }
    }
}
