import SwiftUI

struct WeekSummaryView: View {
    @EnvironmentObject private var store: Store
    let weekNumber: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                // This Week vs Last Week
                SectionHeader(title: "This Week vs Last Week")
                StatBox(title: "Weight (lb)", current: fmt(curr.weightLbs), delta: delta(curr.weightLbs, prev?.weightLbs), direction: .downIsGood)
                StatBox(title: "Waist (in)", current: fmt(curr.waistIn), delta: delta(curr.waistIn, prev?.waistIn), direction: .downIsGood)
                StatBox(title: "Hips (in)", current: fmt(curr.hipsIn), delta: delta(curr.hipsIn, prev?.hipsIn), direction: .downIsGood)
                StatBox(title: "Arm (in)", current: fmt(curr.armIn), delta: delta(curr.armIn, prev?.armIn), direction: .downIsGood)
                StatBox(title: "Thigh (in)", current: fmt(curr.thighIn), delta: delta(curr.thighIn, prev?.thighIn), direction: .downIsGood)
                StatBox(title: "Resting HR", current: fmt(curr.restingHR), delta: delta(curr.restingHR, prev?.restingHR), direction: .downIsGood)
                StatBox(title: "Avg Steps/day", current: fmt(curr.avgDailySteps), delta: delta(curr.avgDailySteps, prev?.avgDailySteps), direction: .upIsGood)
                StatBox(title: "Sleep Score", current: fmt(curr.sleepScore), delta: delta(curr.sleepScore, prev?.sleepScore), direction: .upIsGood)

                Divider().opacity(0.25).padding(.vertical, 8)

                // Since Week 1
                SectionHeader(title: "Since Week 1")
                StatBox(title: "Weight (lb)", current: fmt(curr.weightLbs), delta: delta(curr.weightLbs, week1?.weightLbs), direction: .downIsGood)
                StatBox(title: "Waist (in)", current: fmt(curr.waistIn), delta: delta(curr.waistIn, week1?.waistIn), direction: .downIsGood)
                StatBox(title: "Arm (in)", current: fmt(curr.armIn), delta: delta(curr.armIn, week1?.armIn), direction: .downIsGood)
                StatBox(title: "Thigh (in)", current: fmt(curr.thighIn), delta: delta(curr.thighIn, week1?.thighIn), direction: .downIsGood)
                StatBox(title: "Avg Steps/day", current: fmt(curr.avgDailySteps), delta: delta(curr.avgDailySteps, week1?.avgDailySteps), direction: .upIsGood)

                if !(curr.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                    Divider().opacity(0.25).padding(.vertical, 8)
                    SectionHeader(title: "Notes")
                    Text(curr.notes)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(AppTheme.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
        }
        .background(AppTheme.screenBackground)
    }

    // MARK: - Data

    private var idx: Int { max(0, weekNumber - 1) }

    private var curr: CheckIn {
        guard store.state.weeks.indices.contains(idx) else { return CheckIn() }
        return store.state.weeks[idx].checkIn
    }

    private var prev: CheckIn? {
        let p = idx - 1
        guard store.state.weeks.indices.contains(p) else { return nil }
        return store.state.weeks[p].checkIn
    }

    private var week1: CheckIn? {
        guard store.state.weeks.indices.contains(0) else { return nil }
        return store.state.weeks[0].checkIn
    }

    // MARK: - Formatting / Delta helpers (no forced decimals)

    private func fmt(_ v: Double?) -> String {
        guard let v else { return "—" }
        if v.rounded() == v { return String(Int(v)) }
        return String(v)
    }

    private func fmt(_ v: Int?) -> String {
        guard let v else { return "—" }
        return String(v)
    }

    private func delta(_ a: Double?, _ b: Double?) -> Double? {
        guard let a, let b else { return nil }
        return a - b
    }

    private func delta(_ a: Int?, _ b: Int?) -> Double? {
        guard let a, let b else { return nil }
        return Double(a - b)
    }
}

// MARK: - UI Pieces

private struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(AppTheme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }
}

private enum TrendDirection {
    case downIsGood
    case upIsGood
}

private struct StatBox: View {
    let title: String
    let current: String
    let delta: Double?
    let direction: TrendDirection

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                Text(current)
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.ink)
            }

            Spacer()

            if let delta {
                let status = statusFor(delta: delta)
                Text(deltaText(delta))
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(status.opacity(0.22))
                    .foregroundStyle(status)
                    .clipShape(Capsule())
            } else {
                Text("—")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(AppTheme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func deltaText(_ d: Double) -> String {
        // show integer if whole number
        if d.rounded() == d {
            let i = Int(d)
            return i > 0 ? "+\(i)" : "\(i)"
        }
        return d > 0 ? "+\(d)" : "\(d)"
    }

    private func statusFor(delta d: Double) -> Color {
        let flat = abs(d) < 0.000001
        if flat { return Color.gray }

        let good: Bool = {
            switch direction {
            case .downIsGood: return d < 0
            case .upIsGood: return d > 0
            }
        }()

        return good ? AppTheme.success : AppTheme.warning
    }
}
