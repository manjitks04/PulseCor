//
//  Settings.swift
//  PulseCor
//
import SwiftUI
import Combine
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    @FocusState private var isNameFieldFocused: Bool

    @State private var editedName: String = ""
    @State private var isEditingName: Bool = false
    @ObservedObject private var healthManager = HealthKitManager.shared

    @AppStorage("healthSyncEnabled") private var healthSyncEnabled: Bool = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("dailyCheckInEnabled") private var dailyCheckInEnabled: Bool = true
    @AppStorage("checkInHour") private var checkInHour: Int = 11
    @AppStorage("checkInMinute") private var checkInMinute: Int = 6
    @AppStorage("weeklyReflectionEnabled") private var weeklyReflectionEnabled: Bool = true
    @AppStorage("weeklyReflectionHour") private var weeklyReflectionHour: Int = 18
    @AppStorage("weeklyReflectionMinute") private var weeklyReflectionMinute: Int = 0
    @AppStorage("gentleNudgeEnabled") private var gentleNudgeEnabled: Bool = true

    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var medicationViewModel = MedicationViewModel()
    @State private var showingAddMedication = false
    @State private var medicationToEdit: Medication?

    var currentUser: User? { users.first }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {

                        HStack(spacing: 16) {
                            Image(currentUser?.profilePic ?? "PFP 1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                if isEditingName {
                                    TextField("Name", text: $editedName)
                                        .font(.title2).fontWeight(.bold)
                                        .foregroundColor(Color("MainText"))
                                        .textFieldStyle(.roundedBorder)
                                        .focused($isNameFieldFocused)
                                        .submitLabel(.done)
                                        .onSubmit { saveName() }
                                } else {
                                    Text(currentUser?.name ?? "User")
                                        .font(.title2).fontWeight(.bold)
                                        .foregroundColor(Color("FillBlue"))
                                }

                                Button(action: {
                                    if isEditingName { saveName() }
                                    else {
                                        editedName = currentUser?.name ?? ""
                                        isEditingName = true
                                    }
                                }) {
                                    Text(isEditingName ? "save" : "edit info")
                                        .font(.subheadline)
                                        .foregroundColor(Color("MainText"))
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.top, 20)
                        .padding(.horizontal)
                        .id("settings-name")

                        StreakBadgesSection(currentStreak: currentUser?.currentStreak ?? 0)
                            .id("settings-badges")

                        VStack(alignment: .leading, spacing: 16) {
                            Text("App Appearance")
                                .id("settings-appearance")
                                .font(.title).fontWeight(.semibold)
                                .foregroundColor(Color("TextBlue"))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 12) {
                                VStack(spacing: 16) {
                                    Image("light_mode_preview")
                                        .resizable().aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 200).cornerRadius(16)
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isDarkMode ? Color.clear : Color("AccentCoral"), lineWidth: 2))
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)

                                    Button(action: { isDarkMode = false }) {
                                        HStack(spacing: 8) {
                                            Circle().stroke(Color.blue, lineWidth: 1).frame(width: 16, height: 16)
                                                .overlay(Circle().fill(isDarkMode ? .clear : Color.blue).padding(3))
                                            Text("Light").font(.system(size: 16, weight: .medium)).foregroundColor(Color("TextBlue"))
                                        }
                                    }
                                }

                                VStack(spacing: 16) {
                                    Image("dark_mode_preview")
                                        .resizable().aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 200).cornerRadius(16)
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isDarkMode ? Color("AccentCoral") : Color.clear, lineWidth: 2))
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)

                                    Button(action: { isDarkMode = true }) {
                                        HStack(spacing: 8) {
                                            Circle().stroke(Color.blue, lineWidth: 1).frame(width: 16, height: 16)
                                                .overlay(Circle().fill(isDarkMode ? Color.blue : .clear).padding(3))
                                            Text("Dark").font(.system(size: 16, weight: .medium)).foregroundColor(Color("TextBlue"))
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("Health Data")
                                .id("settings-health")
                                .font(.title).fontWeight(.semibold).foregroundColor(Color("TextBlue"))

                            VStack(spacing: 0) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Apple Health Sync").font(.body).foregroundColor(Color("MainText"))
                                        if healthSyncEnabled {
                                            Text("Connected — reading from Apple Health").font(.caption).foregroundColor(Color("AccentPink"))
                                        } else {
                                            Text("Health metrics will show — on the My Health tab").font(.caption).foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Toggle("", isOn: $healthSyncEnabled).labelsHidden().tint(Color("AccentPink"))
                                        .onChange(of: healthSyncEnabled) { _, newValue in
                                            if newValue {
                                                Task {
                                                    let (success, _) = await HealthKitService.shared.requestAuth()
                                                    if success { await HealthKitService.shared.syncWeeklySummary(context: modelContext) }
                                                    else { healthSyncEnabled = false }
                                                }
                                            } else { settingsViewModel.clearHealthData() }
                                        }
                                }
                                .padding()

                                if !healthSyncEnabled {
                                    Divider().padding(.horizontal)
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "info.circle").font(.caption).foregroundColor(.secondary)
                                        Text("To fully revoke data access, go to the Health app → your profile → Apps & Devices → PulseCor.").font(.caption).foregroundColor(.secondary)
                                    }
                                    .padding()
                                }
                            }
                            .background(Color("CardBG")).cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                        .padding()

                        VStack(alignment: .leading, spacing: 16) {
                            EmptyView().id("settings-notifications")
                            Text("Notifications").font(.title).fontWeight(.semibold).foregroundColor(Color("TextBlue"))

                            VStack(spacing: 12) {
                                HStack {
                                    Text("Daily Check - In").font(.body).foregroundColor(Color("MainText"))
                                    Spacer()
                                    Toggle("", isOn: $dailyCheckInEnabled).labelsHidden().tint(Color("AccentPink"))
                                        .onChange(of: dailyCheckInEnabled) { _, newValue in
                                            if newValue { scheduleDailyCheckInNotification() }
                                            else { NotificationService.shared.cancelDailyCheckIn() }
                                        }
                                }
                                if dailyCheckInEnabled {
                                    TimePickerRow(hour: $checkInHour, minute: $checkInMinute) { scheduleDailyCheckInNotification() }
                                }
                            }
                            .padding().background(Color("CardBG")).cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))

                            VStack(spacing: 12) {
                                HStack {
                                    Text("Weekly Reflection").font(.body).foregroundColor(Color("MainText"))
                                    Spacer()
                                    Toggle("", isOn: $weeklyReflectionEnabled).labelsHidden().tint(Color("AccentPink"))
                                        .onChange(of: weeklyReflectionEnabled) { _, newValue in
                                            if newValue { scheduleWeeklyReflectionNotification() }
                                            else { NotificationService.shared.cancelWeeklyReflection() }
                                        }
                                }
                                if weeklyReflectionEnabled {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Every Sunday at").font(.caption).foregroundColor(Color("MainText").opacity(0.7))
                                        TimePickerRow(hour: $weeklyReflectionHour, minute: $weeklyReflectionMinute) { scheduleWeeklyReflectionNotification() }
                                    }
                                }
                            }
                            .padding().background(Color("CardBG")).cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))

                            VStack(spacing: 12) {
                                HStack {
                                    Text("Gentle Nudge").font(.body).foregroundColor(Color("MainText"))
                                    Spacer()
                                    Toggle("", isOn: $gentleNudgeEnabled).labelsHidden().tint(Color("AccentPink"))
                                        .onChange(of: gentleNudgeEnabled) { _, newValue in
                                            if !newValue { NotificationService.shared.cancelGentleNudge() }
                                        }
                                }
                                Text("Reminds you at 9:30pm if you haven't checked in for 2 days")
                                    .font(.caption).foregroundColor(Color("MainText").opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding().background(Color("CardBG")).cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                        .padding()

                        VStack(alignment: .leading, spacing: 16) {
                            EmptyView().id("settings-medication")
                            HStack {
                                Text("Medication Reminders")
                                    .font(.title).fontWeight(.semibold).foregroundColor(Color("TextBlue"))
                                Spacer()
                                Button(action: { medicationToEdit = nil; showingAddMedication = true }) {
                                    Image(systemName: "plus.circle.fill").font(.system(size: 40)).foregroundColor(Color("AccentCoral"))
                                }
                            }
                            .padding(.horizontal)

                            if medicationViewModel.medications.isEmpty {
                                Text("No medications added yet").font(.subheadline).foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center).padding()
                            } else {
                                ForEach(medicationViewModel.medications) { medication in
                                    MedicationCard(medication: medication) {
                                        medicationToEdit = medication
                                        showingAddMedication = true
                                    }
                                    .contentShape(Rectangle())
                                    .contextMenu {
                                        Button(role: .destructive) { medicationViewModel.deleteMedication(medication) } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        SettingsOnboardingSpacerAdapter()
                    }
                }
                .background(Color("MainBG"))
                .background(SettingsOnboardingScrollAdapter(proxy: proxy))
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
                .task {
                    settingsViewModel.setContext(modelContext)
                    medicationViewModel.setContext(modelContext)
                    if healthSyncEnabled && !OnboardingViewModel.shared.isActive {
                        await HealthKitService.shared.syncWeeklySummary(context: modelContext)
                    }
                }
                .overlay { SettingsOnboardingOverlay() }
            }
        }
        .background(Color("MainBG"))
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showingAddMedication) {
            if let medication = medicationToEdit {
                AddMedicationSheet(viewModel: medicationViewModel, medicationToEdit: medication)
            } else {
                AddMedicationSheet(viewModel: medicationViewModel, medicationToEdit: nil)
            }
        }
        .onChange(of: showingAddMedication) { _, newValue in
            if !newValue { medicationToEdit = nil }
        }
    }

    private func saveName() {
        settingsViewModel.saveName(editedName)
        isEditingName = false
    }

    private func scheduleDailyCheckInNotification() {
        NotificationService.shared.scheduleDailyCheckIn(hour: checkInHour, minute: checkInMinute, isAM: checkInHour < 12)
    }

    private func scheduleWeeklyReflectionNotification() {
        NotificationService.shared.scheduleWeeklyReflection(hour: weeklyReflectionHour, minute: weeklyReflectionMinute, isAM: weeklyReflectionHour < 12)
    }
}

// Only re-renders when isActive or isSettingsStep changes.
private struct SettingsOnboardingSpacerAdapter: View {
    @ObservedObject private var onboarding = OnboardingViewModel.shared

    var body: some View {
        if onboarding.isActive && onboarding.isSettingsStep() {
            Spacer().frame(height: 300)
        }
    }
}

// SettingsView never re-renders when onboarding step changes.
private struct SettingsOnboardingScrollAdapter: View {
    @ObservedObject private var onboarding = OnboardingViewModel.shared
    let proxy: ScrollViewProxy

    var body: some View {
        Color.clear
            .onChange(of: onboarding.currentStep) { _, step in
                withAnimation {
                    switch step {
                    case .settingsName: proxy.scrollTo("settings-name", anchor: .top)
                    case .settingsBadges: proxy.scrollTo("settings-badges", anchor: .top)
                    case .settingsAppearance: proxy.scrollTo("settings-appearance", anchor: .top)
                    case .settingsHealth: proxy.scrollTo("settings-health", anchor: .top)
                    case .settingsNotifications: proxy.scrollTo("settings-notifications", anchor: .top)
                    case .settingsMedication: proxy.scrollTo("settings-medication", anchor: .top)
                    default: break
                    }
                }
            }
    }
}

private struct TimePickerRow: View {
    @Binding var hour: Int
    @Binding var minute: Int
    let onChange: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            HStack(spacing: 4) {
                Button(action: { hour = hour > 0 ? hour - 1 : 23; onChange() }) {
                    Image(systemName: "minus.circle.fill").foregroundColor(Color("AccentPink").opacity(0.9))
                }
                Text(String(format: "%02d", hour)).font(.body).fontWeight(.semibold).foregroundColor(.white)
                    .frame(width: 40, height: 30).background(Color("AccentCoral")).cornerRadius(8)
                Button(action: { hour = hour < 23 ? hour + 1 : 0; onChange() }) {
                    Image(systemName: "plus.circle.fill").foregroundColor(Color("AccentPink").opacity(0.9))
                }
            }
            Text(":").font(.body).fontWeight(.semibold).foregroundColor(Color("MainText"))
            HStack(spacing: 4) {
                Button(action: { minute = minute > 0 ? minute - 1 : 59; onChange() }) {
                    Image(systemName: "minus.circle.fill").foregroundColor(Color("AccentPink").opacity(0.9))
                }
                Text(String(format: "%02d", minute)).font(.body).fontWeight(.semibold).foregroundColor(.white)
                    .frame(width: 40, height: 30).background(Color("AccentCoral")).cornerRadius(8)
                Button(action: { minute = minute < 59 ? minute + 1 : 0; onChange() }) {
                    Image(systemName: "plus.circle.fill").foregroundColor(Color("AccentPink").opacity(0.9))
                }
            }
        }
    }
}

#Preview {
    SettingsView().modelContainer(for: [User.self, Medication.self, MedicationLog.self])
}
