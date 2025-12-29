//
//  WorkoutVideos.swift
//  Workout Tracker
//

import Foundation

enum WorkoutVideos {
    struct YouTubeVideo {
        let id: String
        let title: String

        var url: URL { URL(string: "https://www.youtube.com/watch?v=\(id)")! }
        var embedURL: URL { URL(string: "https://www.youtube.com/embed/\(id)?playsinline=1")! }
        var thumbnailURL: URL { URL(string: "https://i.ytimg.com/vi/\(id)/hqdefault.jpg")! }
    }

    static func youtubeVideo(for exerciseID: String) -> YouTubeVideo? {
        switch exerciseID {
        case "A_goblet_squat": return YouTubeVideo(id: "MeIiIdhvXT4", title: "Goblet Squat (DB/KB)")
        case "A_one_arm_row":  return YouTubeVideo(id: "roCP6wCXPqo", title: "One-Arm Dumbbell Row")
        case "A_floor_press":  return YouTubeVideo(id: "VmB1G1K7v94", title: "Dumbbell Floor Press")
        case "A_rdl":          return YouTubeVideo(id: "0Y9gYjL0nI0", title: "Dumbbell Romanian Deadlift")
        case "A_glute_bridge": return YouTubeVideo(id: "m2Zx-57cSok", title: "Glute Bridge")

        case "W_walk":         return YouTubeVideo(id: "XG6HO8t9N9g", title: "Walking Form Tips")
        case "W_deadbug":      return YouTubeVideo(id: "8CqPp0t3bY4", title: "Dead Bug")
        case "W_side_plank":   return YouTubeVideo(id: "K2VljzCC16g", title: "Side Plank")

        case "B_rdl":          return YouTubeVideo(id: "0Y9gYjL0nI0", title: "Dumbbell RDL")
        case "B_overhead_press": return YouTubeVideo(id: "qEwKCR5JCog", title: "Overhead Press")
        case "B_pull_aparts":  return YouTubeVideo(id: "pFfOqS7uS9Q", title: "Band Pull-Apart")
        case "B_stepups":      return YouTubeVideo(id: "yQmG8mVn7yA", title: "Step Up")
        case "B_glute_kickback": return YouTubeVideo(id: "m8bP0uV1S0k", title: "Band Glute Kickback")

        case "C_split_squat":  return YouTubeVideo(id: "2C-uNgKwPLE", title: "Split Squat")
        case "C_kb_deadlift":  return YouTubeVideo(id: "1uDiW5--rAE", title: "Kettlebell Deadlift")
        case "C_row":          return YouTubeVideo(id: "pYcpY20QaE8", title: "Supported Row")
        case "C_press":        return YouTubeVideo(id: "8iPEnn-ltC8", title: "Incline Dumbbell Press")
        case "C_curls":        return YouTubeVideo(id: "zC3nLlEvin4", title: "Hammer Curl")
        case "C_triceps_ext":  return YouTubeVideo(id: "kE1pX6FZx4c", title: "Overhead Triceps Extension")

        case "S_bridge":       return YouTubeVideo(id: "m2Zx-57cSok", title: "Glute Bridge")
        case "S_lateral":      return YouTubeVideo(id: "1S7lWJ2wqz0", title: "Band Lateral Walk")
        case "S_lateral_raise":return YouTubeVideo(id: "3VcKaXpzqRo", title: "Lateral Raise")

        default: return nil
        }
    }
}//
//  WorkoutVideos.swift
//  Workout Tracker
//
//  Created by Justin Tiano on 12/29/25.
//

