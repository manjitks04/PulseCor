//
//  Health.swift
//  PulseCor
//
import SwiftUI
import SwiftData

struct HealthView: View {
    let stepEntries: [StepEntry]
    let heartRateEntries: [HeartRateEntry]
    let restingEntries: [RestingHeartRateEntry]
    let hrvEntries: [HRVEntry]

    @Environment(\.modelContext) private var context
    @Query private var users: [User]

    @StateObject private var viewModel = HealthViewModel()
    @AppStorage("healthSyncEnabled") private var healthSyncEnabled: Bool = false

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
                                    if viewModel.isSyncing {
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
                            unit: "steps today",
                            gradientColors: [Color("AccentCoral"), Color("AccentPink")],
                            infoText: "Total steps counted by your iPhone or Apple Watch in the last 24 hours. Read from Apple Health."
                        )

                        HealthMetricCard(
                            icon: "heart.fill",
                            title: "Heart Rate",
                            value: heartRateEntries.first.map { "\(Int($0.bpm))" } ?? "--",
                            unit: "BPM average",
                            gradientColors: [Color("AccentPink"), Color("LightPurple")],
                            infoText: "Average heart rate over the last 7 days. Measured continuously by your Apple Watch and stored in Apple Health."
                        )

                        HealthMetricCard(
                            icon: "bed.double.fill",
                            title: "Resting Heart Rate",
                            value: restingEntries.first.map { "\(Int($0.bpm))" } ?? "--",
                            unit: "BPM resting",
                            gradientColors: [Color("FillBlue"), Color("LightPurple")],
                            infoText: "Your heart rate when fully at rest, calculated daily by Apple Watch. A lower resting heart rate generally indicates better cardiovascular fitness."
                        )

                        HealthMetricCard(
                            icon: "waveform.path.ecg",
                            title: "Heart Rate Variability",
                            value: hrvEntries.first.map { String(format: "%.1f", $0.ms) } ?? "--",
                            unit: "ms SDNN",
                            gradientColors: [Color("LightGreen"), Color("FillBlue")],
                            infoText: "HRV measures the variation in time between heartbeats (SDNN). Higher values typically indicate better recovery and stress resilience. Requires Apple Watch."
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
                viewModel.setContext(context)
                if !OnboardingViewModel.shared.isActive {
                    await viewModel.syncIfNeeded(
                        healthSyncEnabled: healthSyncEnabled,
                        lastSyncDate: stepEntries.first?.date
                    )
                }
            }
        }
    }
}

#Preview {
    HealthView(
        stepEntries: [],
        heartRateEntries: [],
        restingEntries: [],
        hrvEntries: []
    )
}
