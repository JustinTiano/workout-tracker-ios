//
//  Theme.swift
//  Workout Tracker
//
//  Created by Justin Tiano on 12/28/25.
//

import SwiftUI

// MARK: - App Theme

enum AppTheme {
    // Muted earthy olive palette (modern + Dark Mode friendly)
    static let olive = Color(red: 0x5F / 255.0, green: 0x66 / 255.0, blue: 0x36 / 255.0) // darker olive
    static let sage  = Color(red: 0xA3 / 255.0, green: 0xAD / 255.0, blue: 0x7A / 255.0) // #A3AD7A
    static let sand  = Color(red: 0xE8 / 255.0, green: 0xE4 / 255.0, blue: 0xD8 / 255.0) // #E8E4D8

    // Primary text color (adapts automatically)
    static let ink = Color(uiColor: .label)

    // Adaptive backgrounds (great contrast in Light/Dark)
    static let screenBackground = Color(uiColor: .systemGroupedBackground)
    static let surface          = Color(uiColor: .systemBackground)
    static let surfaceElevated  = Color(uiColor: .secondarySystemGroupedBackground)

    // Status colors
    static let success = Color(uiColor: .systemGreen)
    static let danger  = Color(uiColor: .systemRed)

    // Trend / feedback colors
    static let warning = Color(uiColor: .systemYellow)
    static let muted   = Color(uiColor: .tertiaryLabel)

    // Calendar states
    static let calendarComplete   = Color(uiColor: .systemGreen)
    static let calendarIncomplete = Color(red: 0xC4 / 255.0, green: 0xB9 / 255.0, blue: 0x6A / 255.0) // warm olive-gold
    static let calendarMissed     = Color(uiColor: .systemRed)

    enum CardKind {
        case hero
        case softCoral
        case softBlue
    }

    /// Common card backgrounds used throughout the app.
    /// Returns `some View` to allow gradients/overlays without repeating styling logic everywhere.
    @ViewBuilder
    static func cardBackground(_ kind: CardKind) -> some View {
        switch kind {
        case .hero:
            ZStack {
                surface
                LinearGradient(
                    colors: [olive.opacity(0.22), sage.opacity(0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

        case .softCoral:
            ZStack {
                surface
                sand.opacity(0.55)
            }

        case .softBlue:
            ZStack {
                surface
                sage.opacity(0.18)
            }
        }
    }

    enum TrendState {
        case good
        case warning
        case neutral

        var color: Color {
            switch self {
            case .good: return AppTheme.success
            case .warning: return AppTheme.warning
            case .neutral: return AppTheme.sage.opacity(0.35)
            }
        }
    }

    static func calendarDayFill(_ state: CalendarDayState) -> Color {
        switch state {
        case .complete:
            return calendarComplete.opacity(0.22)
        case .incomplete:
            return calendarIncomplete.opacity(0.35)
        case .missed:
            return calendarMissed.opacity(0.22)
        case .upcoming:
            return Color.clear
        }
    }
}

// MARK: - Convenience Modifiers

extension View {
    /// Standard rounded card style with subtle border.
    func themedCard(cornerRadius: CGFloat = 16) -> some View {
        self
            .padding()
            .background(AppTheme.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppTheme.sage.opacity(0.18), lineWidth: 1)
            )
    }
}

enum CalendarDayState {
    case complete
    case incomplete
    case missed
    case upcoming
}
