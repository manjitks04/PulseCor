//
//  Health.swift
//  PulseCor
//
//  Created by Manjit Somal on 18/02/2026.
//
import SwiftUI
import SwiftData

struct HealthView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \StepEntry.date, order: .reverse) private var stepEntries: [StepEntry]
    @Query(sort: \HeartRateEntry.date, order: .reverse) private var heartRateEntries: [HeartRateEntry]
    @Query(sort: \RestingHeartRateEntry.date, order: .reverse) private var restingEntries: [RestingHeartRateEntry]
    @Query(sort: \HRVEntry.date, order: .reverse) private var hrvEntries: [HRVEntry]
    @Query private var users: [User]
    @State private var isSyncing = false

    private var shouldSync: Bool {
        guard let lastSync = stepEntries.first?.date else { return true }
        return Date().timeIntervalSince(lastSync) > 3600
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Health")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("MainText"))
                                HStack(spacing: 6) {
                                    Text("Last 7 days")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    if isSyncing {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 55)

                        HealthMetricCard(
                            icon: "figure.walk",
                            title: "Steps",
                            value: stepEntries.first.map { "\(Int($0.count))" } ?? "--",
                            unit: "steps this week",
                            gradientColors: [Color("AccentCoral"), Color("AccentPink")]
                        )

                        HealthMetricCard(
                            icon: "heart.fill",
                            title: "Heart Rate",
                            value: heartRateEntries.first.map { "\(Int($0.bpm))" } ?? "--",
                            unit: "BPM average",
                            gradientColors: [Color("AccentPink"), Color("LightPurple")]
                        )

                        HealthMetricCard(
                            icon: "bed.double.fill",
                            title: "Resting Heart Rate",
                            value: restingEntries.first.map { "\(Int($0.bpm))" } ?? "--",
                            unit: "BPM resting",
                            gradientColors: [Color("FillBlue"), Color("LightPurple")]
                        )

                        HealthMetricCard(
                            icon: "waveform.path.ecg",
                            title: "Heart Rate Variability",
                            value: hrvEntries.first.map { String(format: "%.1f", $0.ms) } ?? "--",
                            unit: "ms SDNN",
                            gradientColors: [Color("LightGreen"), Color("FillBlue")]
                        )

                        Text("Data sourced from Apple Health")
                            .font(.appSmallBody)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)

                    if let currentUser = users.first {
                        ProfileButton(user: currentUser)
                            .padding(.trailing, 16)
                            .padding(.top, 20)
                    }
                }
            }
            .background(Color("MainBG"))
            .navigationBarHidden(true)
            .task {
                guard shouldSync else { return }
                isSyncing = true
                let (success, _) = await HealthKitService.shared.requestAuth()
                guard success else { isSyncing = false; return }
                HealthKitService.shared.syncWeeklySummary(context: context)
                try? await Task.sleep(for: .seconds(2))
                isSyncing = false
            }
        }
    }
}

#Preview {
    HealthView()
}

