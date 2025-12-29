//
//  Store.swift
//  Workout Tracker
//
//  Created by Justin Tiano on 12/28/25.
//

import Foundation
import SwiftUI

// MARK: - Storage

protocol Storage {
    func load() -> AppState?
    func save(_ state: AppState)
    func clear()
}

final class FileStorage: Storage {
    private let url: URL

    init(filename: String = "workout_tracker_state.json") {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.url = dir.appendingPathComponent(filename)
    }

    func load() -> AppState? {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(AppState.self, from: data)
        } catch {
            return nil
        }
    }

    func save(_ state: AppState) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(state)
            try data.write(to: url, options: [.atomic])
        } catch {
            // ignore write failures
        }
    }

    func clear() {
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: - Store

@MainActor
final class Store: ObservableObject {
    @Published var state: AppState {
        didSet { storage.save(state) }
    }

    private let storage: Storage

    init(storage: Storage = FileStorage()) {
        self.storage = storage
        if let loaded = storage.load() {
            self.state = loaded
        } else {
            self.state = AppState()
        }

        // Ensure weeks exist
        if state.weeks.isEmpty {
            var s = state
            s.weeks = AppState.freshProgram(weeks: 12)
            state = s
        }

        // MIGRATION: if startDate is in the future (e.g., old "next Monday" behavior),
        // force it to TODAY so Week 1 Day 1 = today (12/29).
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        if let sd = state.startDate {
            let s0 = cal.startOfDay(for: sd)
            if s0 > today {
                var s = state
                s.startDate = today
                state = s
            }
        }
    }

    var isOnboarded: Bool {
        state.profile != nil && state.startDate != nil
    }

    // MARK: - Safe mutations (ensure @Published publishes)

    func setCheckIn(weekNumber: Int, checkIn: CheckIn) {
        var s = state
        let idx = max(0, weekNumber - 1)
        guard s.weeks.indices.contains(idx) else { return }
        s.weeks[idx].checkIn = checkIn
        state = s
    }

    func setExerciseDone(weekNumber: Int, dayIndex: Int, exerciseID: String, done: Bool) {
        var s = state
        let wIdx = max(0, weekNumber - 1)
        guard s.weeks.indices.contains(wIdx), s.weeks[wIdx].days.indices.contains(dayIndex) else { return }
        s.weeks[wIdx].days[dayIndex].exerciseDone[exerciseID] = done
        state = s
    }

    func setDayNotes(weekNumber: Int, dayIndex: Int, notes: String) {
        var s = state
        let wIdx = max(0, weekNumber - 1)
        guard s.weeks.indices.contains(wIdx), s.weeks[wIdx].days.indices.contains(dayIndex) else { return }
        s.weeks[wIdx].days[dayIndex].notes = notes
        state = s
    }

    // MARK: - Onboarding

    func completeOnboarding(name: String, preset: Preset) {
        var s = state
        s.profile = UserProfile(displayName: name, preset: preset)

        if s.weeks.isEmpty {
            s.weeks = AppState.freshProgram(weeks: 12)
        }

        // Start program TODAY (Week 1 Day 1 = today)
        let cal = Calendar.current
        s.startDate = cal.startOfDay(for: Date())

        state = s
    }

    // MARK: - Reset

    func resetAll() {
        storage.clear()
        var s = AppState()
        s.weeks = AppState.freshProgram(weeks: 12)
        state = s
    }
}
