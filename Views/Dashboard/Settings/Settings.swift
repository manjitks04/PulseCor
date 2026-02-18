//
//  Settings.swift
//  PulseCor
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @FocusState private var isNameFieldFocused: Bool
    
    @State private var editedName: String = ""
    @State private var isEditingName: Bool = false
    @State private var healthSyncEnabled: Bool = false
    @State private var healthAuthorizationStatus: String = "Not Connected"
    @ObservedObject private var healthManager = HealthKitManager.shared

    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("dailyCheckInEnabled") private var dailyCheckInEnabled: Bool = true
    @AppStorage("checkInHour") private var checkInHour: Int = 11
    @AppStorage("checkInMinute") private var checkInMinute: Int = 6
    @AppStorage("isAM") private var isAM: Bool = true
    
    @AppStorage("weeklyReflectionEnabled") private var weeklyReflectionEnabled: Bool = true
    @AppStorage("weeklyReflectionHour") private var weeklyReflectionHour: Int = 18
    @AppStorage("weeklyReflectionMinute") private var weeklyReflectionMinute: Int = 0
    @AppStorage("weeklyReflectionIsAM") private var weeklyReflectionIsAM: Bool = false
    
    @State private var showingHealthError: Bool = false
    @State private var healthErrorMessage: String = ""
    
    @StateObject private var medicationViewModel = MedicationViewModel()
    @State private var showingAddMedication = false
    @State private var medicationToEdit: Medication?

    
    var currentUser: User? {
        users.first
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Text("X")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color("MainText"))
                }
                
                Spacer()
                
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("MainText"))
                
                Spacer()
                
                Text("X")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.clear)
            }
            .padding()
            .background(Color("MainBG"))
            
            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("profile")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if isEditingName {
                                TextField("Name", text: $editedName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("MainText"))
                                    .textFieldStyle(.roundedBorder)
                                    .focused($isNameFieldFocused)
                                    .submitLabel(.done)
                                    .onSubmit { saveName() }
                            } else {
                                Text(currentUser?.name ?? "User")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("FillBlue"))
                            }
                            
                            Button(action: {
                                if isEditingName {
                                    saveName()
                                } else {
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
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("App Appearance")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TextBlue"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            VStack(spacing: 16) {
                                Image("light_mode_preview")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150, height: 200)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(isDarkMode ? Color.clear : Color("AccentCoral"), lineWidth: 2)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)

                                Button(action: { isDarkMode = false }) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .stroke(Color.blue, lineWidth: 1)
                                            .frame(width: 16, height: 16)
                                            .overlay(
                                                Circle()
                                                    .fill(isDarkMode ? .clear : Color.blue)
                                                    .padding(3)
                                            )
                                        
                                        Text("Light")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color("TextBlue"))
                                    }
                                }
                            }
                            
                            VStack(spacing: 16) {
                                Image("dark_mode_preview")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150, height: 200)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(isDarkMode ? Color("AccentCoral") : Color.clear, lineWidth: 2)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                
                                Button(action: { isDarkMode = true }) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .stroke(Color.blue, lineWidth: 1)
                                            .frame(width: 16, height: 16)
                                            .overlay(
                                                Circle()
                                                    .fill(isDarkMode ? Color.blue : .clear)
                                                    .padding(3)
                                            )
                                        
                                        Text("Dark")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color("TextBlue"))
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Health Data")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TextBlue"))
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Apple Health Sync")
                                    .font(.body)
                                    .foregroundColor(Color("MainText"))
                                
                                if HealthKitManager.shared.isAuthorized {
                                    Text("Connected — reading from Apple Health")
                                        .font(.caption)
                                        .foregroundColor(Color("AccentPink"))
                                } else {
                                    HStack(spacing: 4) {
                                        Image(systemName: "info.circle")
                                            .font(.caption)
                                            .foregroundColor(.pink.opacity(0.7))
                                        Text("To disconnect, open the Health app → your profile → Apps & Devices")
                                            .font(.caption)
                                            .foregroundColor(Color("AccentCoral"))
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $healthSyncEnabled)
                                .labelsHidden()
                                .tint(Color("AccentPink"))
                                .onChange(of: healthSyncEnabled) { oldValue, newValue in
                                    if newValue {
                                        requestHealthKitAuth()
                                    }
                                }
                        }
                        .padding()
                        .background(Color("CardBG"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notifications")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TextBlue"))
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Daily Check - In")
                                    .font(.body)
                                    .foregroundColor(Color("MainText"))
                                
                                Spacer()
                                
                                Toggle("", isOn: $dailyCheckInEnabled)
                                    .labelsHidden()
                                    .tint(Color("AccentPink"))
                                    .onChange(of: dailyCheckInEnabled) { oldValue, newValue in
                                        if newValue {
                                            scheduleDailyCheckInNotification()
                                        } else {
                                            NotificationService.shared.cancelDailyCheckIn()
                                        }
                                    }
                            }
                            
                            if dailyCheckInEnabled {
                                HStack(spacing: 12) {
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Button(action: {
                                            if checkInHour > 1 {
                                                checkInHour -= 1
                                            } else {
                                                checkInHour = 12
                                            }
                                            scheduleDailyCheckInNotification()
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(Color("AccentPink").opacity(0.9))
                                        }
                                        
                                        Text(String(format: "%02d", checkInHour))
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 30)
                                            .background(Color("AccentCoral"))
                                            .cornerRadius(8)
                                        
                                        Button(action: {
                                            if checkInHour < 12 {
                                                checkInHour += 1
                                            } else {
                                                checkInHour = 1
                                            }
                                            scheduleDailyCheckInNotification()
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(Color("AccentPink").opacity(0.9))
                                        }
                                    }
                                    
                                    HStack(spacing: 4) {
                                        Button(action: {
                                            if checkInMinute > 0 {
                                                checkInMinute -= 1
                                            } else {
                                                checkInMinute = 59
                                            }
                                            scheduleDailyCheckInNotification()
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(Color("AccentPink").opacity(0.9))
                                        }
                                        
                                        Text(String(format: "%02d", checkInMinute))
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 30)
                                            .background(Color("AccentCoral"))
                                            .cornerRadius(8)
                                        
                                        Button(action: {
                                            if checkInMinute < 59 {
                                                checkInMinute += 1
                                            } else {
                                                checkInMinute = 0
                                            }
                                            scheduleDailyCheckInNotification()
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(Color("AccentPink").opacity(0.9))
                                        }
                                    }
                                    
                                    Button(action: {
                                        isAM.toggle()
                                        scheduleDailyCheckInNotification()
                                    }) {
                                        Text(isAM ? "AM" : "PM")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(width: 50, height: 30)
                                            .background(Color("AccentCoral").opacity(0.9))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color("CardBG"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Weekly Reflection")
                                    .font(.body)
                                    .foregroundColor(Color("MainText"))
                                
                                Spacer()
                                
                                Toggle("", isOn: $weeklyReflectionEnabled)
                                    .labelsHidden()
                                    .tint(Color("AccentPink"))
                                    .onChange(of: weeklyReflectionEnabled) { oldValue, newValue in
                                        if newValue {
                                            scheduleWeeklyReflectionNotification()
                                        } else {
                                            NotificationService.shared.cancelWeeklyReflection()
                                        }
                                    }
                            }
                            
                            if weeklyReflectionEnabled {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Every Sunday at")
                                        .font(.caption)
                                        .foregroundColor(Color("MainText").opacity(0.7))
                                    
                                    HStack(spacing: 12) {
                                        Spacer()
                                        
                                        HStack(spacing: 4) {
                                            Button(action: {
                                                if weeklyReflectionHour > 1 {
                                                    weeklyReflectionHour -= 1
                                                } else {
                                                    weeklyReflectionHour = 12
                                                }
                                                scheduleWeeklyReflectionNotification()
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(Color("AccentPink").opacity(0.9))
                                            }
                                            
                                            Text(String(format: "%02d", weeklyReflectionHour))
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .frame(width: 40, height: 30)
                                                .background(Color("AccentCoral"))
                                                .cornerRadius(8)
                                            
                                            Button(action: {
                                                if weeklyReflectionHour < 12 {
                                                    weeklyReflectionHour += 1
                                                } else {
                                                    weeklyReflectionHour = 1
                                                }
                                                scheduleWeeklyReflectionNotification()
                                            }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .foregroundColor(Color("AccentPink").opacity(0.9))
                                            }
                                        }
                                        
                                        HStack(spacing: 4) {
                                            Button(action: {
                                                if weeklyReflectionMinute > 0 {
                                                    weeklyReflectionMinute -= 1
                                                } else {
                                                    weeklyReflectionMinute = 59
                                                }
                                                scheduleWeeklyReflectionNotification()
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(Color("AccentPink").opacity(0.9))
                                            }
                                            
                                            Text(String(format: "%02d", weeklyReflectionMinute))
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .frame(width: 40, height: 30)
                                                .background(Color("AccentCoral"))
                                                .cornerRadius(8)
                                            
                                            Button(action: {
                                                if weeklyReflectionMinute < 59 {
                                                    weeklyReflectionMinute += 1
                                                } else {
                                                    weeklyReflectionMinute = 0
                                                }
                                                scheduleWeeklyReflectionNotification()
                                            }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .foregroundColor(Color("AccentPink").opacity(0.9))
                                            }
                                        }
                                        
                                        Button(action: {
                                            weeklyReflectionIsAM.toggle()
                                            scheduleWeeklyReflectionNotification()
                                        }) {
                                            Text(weeklyReflectionIsAM ? "AM" : "PM")
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .frame(width: 50, height: 30)
                                                .background(Color("AccentCoral").opacity(0.9))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color("CardBG"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Medication Reminders")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("TextBlue"))
                            
                            Spacer()
                            
                            Button(action: {
                                medicationToEdit = nil
                                showingAddMedication = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color("AccentCoral"))
                            }
                        }
                        .padding(.horizontal)
                        
                        if medicationViewModel.medications.isEmpty {
                            Text("No medications added yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(medicationViewModel.medications) { medication in
                                MedicationCard(medication: medication) {
                                    medicationToEdit = medication
                                    showingAddMedication = true
                                }
                                .contentShape(Rectangle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if let id = medication.id {
                                            medicationViewModel.deleteMedication(medicationId: id)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .background(Color("MainBG"))
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
            if !newValue {
                medicationToEdit = nil
            }
        }
    }
    
    private func saveName() {
        guard let user = currentUser, !editedName.isEmpty else { return }
        user.name = editedName
        try? modelContext.save()
        isEditingName = false
    }
    
    private func requestHealthKitAuth() {
        HealthKitService.shared.requestAuth { success, error in
            DispatchQueue.main.async {
                    if !success {
                        let pulseError = PulseCorError.healthKitAuthFailed(
                            error?.localizedDescription ?? "Unknown error"
                        )
                        healthErrorMessage = pulseError.errorDescription ?? "Failed to authorize HealthKit"
                        showingHealthError = true
                    }
                }
            }
        }
    
    private func scheduleDailyCheckInNotification() {
        NotificationService.shared.scheduleDailyCheckIn(
            hour: checkInHour,
            minute: checkInMinute,
            isAM: isAM
        )
    }
    
    private func scheduleWeeklyReflectionNotification() {
        NotificationService.shared.scheduleWeeklyReflection(
            hour: weeklyReflectionHour,
            minute: weeklyReflectionMinute,
            isAM: weeklyReflectionIsAM
        )
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [User.self])
}
