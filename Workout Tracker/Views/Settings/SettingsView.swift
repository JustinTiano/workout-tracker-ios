
//
//  SettingsView.swift
//  Workout Tracker
//
//  Created by Justin Tiano on 12/28/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    profileCard
                    dataCard
                }
                .padding()
            }
            .background(AppTheme.screenBackground)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("Reset everything?", isPresented: $showResetConfirm) {
                Button("Reset App", role: .destructive) { store.resetAll() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This clears your profile, calendar progress, and all check-ins. This cannot be undone.")
            }
        }
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Profile", systemImage: "person.crop.circle")
                .font(.headline)

            if let profile = store.state.profile {
                HStack {
                    Text("Name")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(profile.displayName)
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("Preset")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(profile.preset.rawValue)
                        .fontWeight(.semibold)
                }

                Text("Your preset is locked after setup. To change it, reset the app.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("No profile set")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(AppTheme.cardBackground(.softBlue))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var dataCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Data", systemImage: "externaldrive")
                .font(.headline)

            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Text("Reset App")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.olive)

            Text("Reset is the only way to change presets or restart the 12-week program.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(AppTheme.cardBackground(.softCoral))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SettingsView()
        .environmentObject(Store())
}
