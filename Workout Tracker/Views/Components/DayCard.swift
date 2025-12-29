//
//  DayCard.swift
//  Workout Tracker
//
//  Created by Justin Tiano on 12/28/25.
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.title3)
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

struct DayCard: View {
    @EnvironmentObject private var store: Store

    let weekNumber: Int
    let day: DayOfWeek
    let preset: Preset

    private var weekIndex: Int { max(0, weekNumber - 1) }

    var body: some View {
        let dayIndex = DayOfWeek.allCases.firstIndex(of: day) ?? 0
        let exercises = WorkoutLibrary.workoutExercises(for: day, preset: preset)
        let required = exercises.filter { !$0.isOptional }

        let doneCount = required.filter { isExerciseDone(dayIndex: dayIndex, exerciseId: $0.id) }.count
        let isComplete = !required.isEmpty && doneCount == required.count

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(day.rawValue)
                    .font(.headline)
                Spacer()
                Text("\(doneCount)/\(required.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.sand.opacity(0.45))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(exercises) { ex in
                    Toggle(isOn: bindingExerciseDone(dayIndex: dayIndex, exerciseId: ex.id)) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(ex.name)
                                    .font(.subheadline.weight(.semibold))

                                if ex.isOptional {
                                    Text("Optional")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(AppTheme.sage.opacity(0.18))
                                        .clipShape(Capsule())
                                }
                            }

                            Text(detailsText(for: ex))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(CheckboxToggleStyle())
                }
            }

            TextField("Notes…", text: bindingNotes(dayIndex: dayIndex), axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isComplete ? AppTheme.success.opacity(0.70) : AppTheme.sage.opacity(0.12), lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isComplete ? AppTheme.success.opacity(0.10) : Color.clear)
                )
        )
    }

    private func detailsText(for ex: Exercise) -> String {
        // Example: "3×8–10 • Rec: 10/hand" or just "30–45 minutes"
        if ex.recommended.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return ex.prescription
        }
        return "\(ex.prescription) • Rec: \(ex.recommended)"
    }

    private func isExerciseDone(dayIndex: Int, exerciseId: String) -> Bool {
        guard store.state.weeks.indices.contains(weekIndex), store.state.weeks[weekIndex].days.indices.contains(dayIndex) else {
            return false
        }
        return store.state.weeks[weekIndex].days[dayIndex].exerciseDone[exerciseId] ?? false
    }

    private func bindingExerciseDone(dayIndex: Int, exerciseId: String) -> Binding<Bool> {
        Binding(
            get: {
                guard store.state.weeks.indices.contains(weekIndex), store.state.weeks[weekIndex].days.indices.contains(dayIndex) else {
                    return false
                }
                return store.state.weeks[weekIndex].days[dayIndex].exerciseDone[exerciseId] ?? false
            },
            set: { newValue in
                guard store.state.weeks.indices.contains(weekIndex), store.state.weeks[weekIndex].days.indices.contains(dayIndex) else {
                    return
                }
                store.state.weeks[weekIndex].days[dayIndex].exerciseDone[exerciseId] = newValue
            }
        )
    }

    private func bindingNotes(dayIndex: Int) -> Binding<String> {
        Binding(
            get: {
                guard store.state.weeks.indices.contains(weekIndex), store.state.weeks[weekIndex].days.indices.contains(dayIndex) else {
                    return ""
                }
                return store.state.weeks[weekIndex].days[dayIndex].notes
            },
            set: { newValue in
                guard store.state.weeks.indices.contains(weekIndex), store.state.weeks[weekIndex].days.indices.contains(dayIndex) else {
                    return
                }
                store.state.weeks[weekIndex].days[dayIndex].notes = newValue
            }
        )
    }
}

#Preview {
    DayCard(weekNumber: 1, day: .monday, preset: .justin)
        .environmentObject(Store())
}
