//
//  WorkoutTrackerApp.swift
//  Workout Tracker
//
//  Created by Justin Tiano on 12/28/25.
//

import SwiftUI

@main
struct Workout_TrackerApp: App {
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .tint(AppTheme.olive)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        Group {
            if store.isOnboarded {
                MainTabsView()
            } else {
                OnboardingView()
            }
        }
    }
}

struct MainTabsView: View {
    var body: some View {
        DashboardView()
    }
}

#Preview {
    RootView()
        .environmentObject(Store())
}  Ï
