
//
//  OnboardingView.swift
//  Workout Tracker
//
//  Created by Justin Tiano on 12/28/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome ✨")
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppTheme.ink)

                    Text("Tap your name to lock in your preset. (If you ever need to change it, use Reset in Settings.)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 12) {
                    Button {
                        store.completeOnboarding(name: "Justin", preset: .justin)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Justin")
                                    .font(.headline)
                                Text("Fat-loss + muscle retention")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            Spacer()
                            Image(systemName: "checkmark.seal")
                                .imageScale(.large)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .background(AppTheme.olive)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        store.completeOnboarding(name: "Melissa", preset: .melissa)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Melissa")
                                    .font(.headline)
                                Text("Tone arms + legs + glutes")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "checkmark.seal")
                                .imageScale(.large)
                                .foregroundStyle(AppTheme.olive)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(AppTheme.ink)
                        .background(AppTheme.sand.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppTheme.sage.opacity(0.35), lineWidth: 1)
                        )
                    }
                }
                .padding()
                .background(AppTheme.cardBackground(.softBlue))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Label("Starts next Monday", systemImage: "calendar")
                        .font(.headline)

                    Text("Week 1 Day 1 always lands on a Monday so the calendar + week logic never drift.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(AppTheme.cardBackground(.softCoral))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
            .background(AppTheme.screenBackground)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(Store())
}

