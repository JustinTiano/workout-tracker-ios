//
//  WorkoutLibrary.swift
//  Workout Tracker
//
//  Source of truth for the workout program (12-week schedule uses the same weekly template).
//

import Foundation

enum WorkoutLibrary {

    // MARK: - Public API

    /// Returns the exercises for a given weekday and preset.
    /// - Justin + Custom: default schedule
    /// - Melissa: alternates so she walks when Justin lifts (and vice versa) so you can stay together.
    static func workoutExercises(for day: DayOfWeek, preset: Preset) -> [Exercise] {
        if preset == .melissa {
            // Melissa schedule = opposite on strength vs walk days relative to Justin/default
            switch day {
            case .monday:    return walkAndCore(preset: preset)
            case .tuesday:   return strengthA(preset: preset)
            case .wednesday: return walkAndMobility(preset: preset)
            case .thursday:  return strengthB(preset: preset)
            case .friday:    return walkAndCore(preset: preset)
            case .saturday:  return strengthC(preset: preset)
            case .sunday:    return restAndReset(preset: preset)
            }
        }

        // Justin + Custom (default)
        switch day {
        case .monday:    return strengthA(preset: preset)
        case .tuesday:   return walkAndCore(preset: preset)
        case .wednesday: return strengthB(preset: preset)
        case .thursday:  return walkAndMobility(preset: preset)
        case .friday:    return strengthC(preset: preset)
        case .saturday:  return saturdayGluteArms(preset: preset)
        case .sunday:    return restAndReset(preset: preset)
        }
    }

    // MARK: - Recommended Loads (string labels shown in UI)

    struct ExerciseWeights {
        let justin: String
        let melissa: String
        let custom: String

        func value(for preset: Preset) -> String {
            switch preset {
            case .justin: return justin
            case .melissa: return melissa
            case .custom: return custom
            }
        }
    }

    // MARK: - Workouts

    // Strength Day A: squat + push + pull + glutes + arms
    private static func strengthA(preset: Preset) -> [Exercise] {
        let goblet     = ExerciseWeights(justin: "10–15 lb",     melissa: "5–10 lb",     custom: "Light–Moderate")
        let floorPress = ExerciseWeights(justin: "5–10 lb/hand",  melissa: "2–5 lb/hand", custom: "Light–Moderate")
        let row        = ExerciseWeights(justin: "10–15 lb",      melissa: "5–10 lb",     custom: "Light–Moderate")
        let bridge     = ExerciseWeights(justin: "15–25 lb",      melissa: "10–15 lb",    custom: "Light–Moderate")
        let curls      = ExerciseWeights(justin: "5–10 lb/hand",  melissa: "2–5 lb/hand", custom: "Light")
        let triceps    = ExerciseWeights(justin: "Band (med)",    melissa: "Band (light)",custom: "Band (light-med)")

        return [
            Exercise(id: "A_warmup", name: "Warm-up (5 min)",
                     prescription: "March + arm circles + bodyweight squats",
                     recommended: "Easy", isOptional: false),

            Exercise(id: "A_goblet_squat", name: "Goblet Squat",
                     prescription: "3×8–10",
                     recommended: goblet.value(for: preset), isOptional: false),

            Exercise(id: "A_floor_press", name: "Dumbbell Floor Press",
                     prescription: "3×8–10",
                     recommended: floorPress.value(for: preset), isOptional: false),

            Exercise(id: "A_one_arm_row", name: "One-Arm Dumbbell Row",
                     prescription: "3×10/side",
                     recommended: row.value(for: preset), isOptional: false),

            Exercise(id: "A_glute_bridge", name: "Weighted Glute Bridge",
                     prescription: "3×12",
                     recommended: bridge.value(for: preset), isOptional: false),

            Exercise(id: "A_biceps_curl", name: "Biceps Curl",
                     prescription: "2×10–12",
                     recommended: curls.value(for: preset), isOptional: false),

            Exercise(id: "A_triceps_pressdown", name: "Band Triceps Pressdown",
                     prescription: "2×12–15",
                     recommended: triceps.value(for: preset), isOptional: false)
        ]
    }

    // Walk day with low-fatigue core
    private static func walkAndCore(preset: Preset) -> [Exercise] {
        _ = preset
        return [
            Exercise(id: "W_walk", name: "Walk (pad or outside)",
                     prescription: "20–35 min",
                     recommended: "RPE 5–6", isOptional: false),

            Exercise(id: "W_deadbug", name: "Dead Bug",
                     prescription: "2×8/side",
                     recommended: "Slow + controlled", isOptional: false),

            Exercise(id: "W_side_plank", name: "Side Plank",
                     prescription: "2×20–30 sec/side",
                     recommended: "Knees down OK", isOptional: false)
        ]
    }

    // Strength Day B: hinge + shoulders/back + glutes
    private static func strengthB(preset: Preset) -> [Exercise] {
        let rdl      = ExerciseWeights(justin: "10–15 lb/hand",   melissa: "5–10 lb/hand", custom: "Light–Moderate")
        let ohp      = ExerciseWeights(justin: "5–8 lb/hand",     melissa: "2–5 lb/hand",  custom: "Light")
        let pullApart = ExerciseWeights(justin: "Band (med)",      melissa: "Band (light)", custom: "Band (light-med)")
        let stepUp   = ExerciseWeights(justin: "Bodyweight",      melissa: "Bodyweight",   custom: "Bodyweight")
        let kickback = ExerciseWeights(justin: "Band (med)",      melissa: "Band (light)", custom: "Band (light-med)")

        return [
            Exercise(id: "B_warmup", name: "Warm-up (5 min)",
                     prescription: "Hip hinge drills + shoulder circles",
                     recommended: "Easy", isOptional: false),

            Exercise(id: "B_rdl", name: "Dumbbell Romanian Deadlift",
                     prescription: "3×8–10",
                     recommended: rdl.value(for: preset), isOptional: false),

            Exercise(id: "B_overhead_press", name: "Overhead Press",
                     prescription: "3×8",
                     recommended: ohp.value(for: preset), isOptional: false),

            Exercise(id: "B_pull_aparts", name: "Band Pull-Aparts",
                     prescription: "3×12–15",
                     recommended: pullApart.value(for: preset), isOptional: false),

            Exercise(id: "B_stepups", name: "Step-Ups (low step)",
                     prescription: "2×10/side",
                     recommended: stepUp.value(for: preset), isOptional: false),

            Exercise(id: "B_glute_kickback", name: "Band Glute Kickback",
                     prescription: "2×12/side",
                     recommended: kickback.value(for: preset), isOptional: false)
        ]
    }

    // Walk + mobility
    private static func walkAndMobility(preset: Preset) -> [Exercise] {
        _ = preset
        return [
            Exercise(id: "M_walk", name: "Walk (pad or outside)",
                     prescription: "20–40 min",
                     recommended: "RPE 5–6", isOptional: false),

            Exercise(id: "M_hip_mob", name: "Hip Mobility Flow",
                     prescription: "6–8 min",
                     recommended: "Slow", isOptional: false),

            Exercise(id: "M_thoracic", name: "Thoracic Openers",
                     prescription: "2×6/side",
                     recommended: "Slow", isOptional: false)
        ]
    }

    // Strength Day C: full body + arms
    private static func strengthC(preset: Preset) -> [Exercise] {
        let splitSquat = ExerciseWeights(justin: "5–10 lb/hand",  melissa: "2–5 lb/hand",  custom: "Light")
        let kbDeadlift = ExerciseWeights(justin: "15–25 lb KB",   melissa: "10–15 lb KB",  custom: "Light–Moderate")
        let row        = ExerciseWeights(justin: "10–15 lb",      melissa: "5–10 lb",      custom: "Light–Moderate")
        let press      = ExerciseWeights(justin: "5–10 lb/hand",  melissa: "2–5 lb/hand",  custom: "Light")
        let curls      = ExerciseWeights(justin: "5–10 lb/hand",  melissa: "2–5 lb/hand",  custom: "Light")
        let triceps    = ExerciseWeights(justin: "5–8 lb",        melissa: "2–5 lb",       custom: "Light")

        return [
            Exercise(id: "C_warmup", name: "Warm-up (5 min)",
                     prescription: "Glute bridges + band pulls",
                     recommended: "Easy", isOptional: false),

            Exercise(id: "C_split_squat", name: "Split Squat",
                     prescription: "3×8/side",
                     recommended: splitSquat.value(for: preset), isOptional: false),

            Exercise(id: "C_kb_deadlift", name: "Kettlebell Deadlift",
                     prescription: "3×10",
                     recommended: kbDeadlift.value(for: preset), isOptional: false),

            Exercise(id: "C_row", name: "Supported Row",
                     prescription: "3×10",
                     recommended: row.value(for: preset), isOptional: false),

            Exercise(id: "C_press", name: "Incline Push-Up or DB Press",
                     prescription: "3×8–10",
                     recommended: press.value(for: preset), isOptional: false),

            Exercise(id: "C_curls", name: "Hammer Curl",
                     prescription: "2×10–12",
                     recommended: curls.value(for: preset), isOptional: false),

            Exercise(id: "C_triceps_ext", name: "Overhead Triceps Extension",
                     prescription: "2×10–12",
                     recommended: triceps.value(for: preset), isOptional: false)
        ]
    }

    // Saturday: light glute + arms (still required)
    private static func saturdayGluteArms(preset: Preset) -> [Exercise] {
        let bridge = ExerciseWeights(justin: "15–25 lb",          melissa: "10–15 lb",     custom: "Light–Moderate")
        let lateral = ExerciseWeights(justin: "Band (med)",        melissa: "Band (light)", custom: "Band (light-med)")
        let raises = ExerciseWeights(justin: "5 lb/hand",         melissa: "2–5 lb/hand",  custom: "Light")

        return [
            Exercise(id: "S_walk", name: "Easy Walk",
                     prescription: "15–30 min",
                     recommended: "Recovery pace", isOptional: false),

            Exercise(id: "S_bridge", name: "Glute Bridge",
                     prescription: "2×12",
                     recommended: bridge.value(for: preset), isOptional: false),

            Exercise(id: "S_lateral", name: "Band Lateral Walk",
                     prescription: "2×10 steps/side",
                     recommended: lateral.value(for: preset), isOptional: false),

            Exercise(id: "S_lateral_raise", name: "Lateral Raises",
                     prescription: "2×10–12",
                     recommended: raises.value(for: preset), isOptional: false)
        ]
    }

    private static func restAndReset(preset: Preset) -> [Exercise] {
        _ = preset
        return [
            Exercise(id: "R_rest", name: "Rest Day",
                     prescription: "No workout",
                     recommended: "Optional easy walk", isOptional: false)
        ]
    }
}
