//
//  AddMedicationSheet.swift
//  PulseCor
//
//

import SwiftUI

struct AddMedicationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MedicationViewModel
    
    let medicationToEdit: Medication?
    
    @State private var medicationName: String
    @State private var dosage: String
    @State private var frequency: String
    @State private var hour: Int
    @State private var minute: Int
    @State private var isAM: Bool
    @State private var enableReminder: Bool
    
    let frequencies = ["Before Breakfast", "After Breakfast", "Before Lunch", "After Lunch", "Before Dinner", "After Dinner", "Before Bed"]
    
    init(viewModel: MedicationViewModel, medicationToEdit: Medication? = nil) {
        self.viewModel = viewModel
        self.medicationToEdit = medicationToEdit
        
        if let medication = medicationToEdit {
            _medicationName = State(initialValue: medication.name)
            _dosage = State(initialValue: medication.dosage)
            _frequency = State(initialValue: medication.frequency)
            _enableReminder = State(initialValue: !(medication.reminderTimes?.isEmpty ?? true))
            
            if let timeString = medication.reminderTimes?.first {
                let components = timeString.split(separator: ":")
                if components.count == 2,
                   let h = Int(components[0]),
                   let m = Int(components[1]) {
                    let isAMValue = h < 12
                    let displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h)
                    _hour = State(initialValue: displayHour)
                    _minute = State(initialValue: m)
                    _isAM = State(initialValue: isAMValue)
                } else {
                    _hour = State(initialValue: 9)
                    _minute = State(initialValue: 0)
                    _isAM = State(initialValue: true)
                }
            } else {
                _hour = State(initialValue: 9)
                _minute = State(initialValue: 0)
                _isAM = State(initialValue: true)
            }
        } else {
            _medicationName = State(initialValue: "")
            _dosage = State(initialValue: "")
            _frequency = State(initialValue: "After Breakfast")
            _hour = State(initialValue: 9)
            _minute = State(initialValue: 0)
            _isAM = State(initialValue: true)
            _enableReminder = State(initialValue: true)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $medicationName)
                    TextField("Dosage (e.g., 250mg)", text: $dosage)
                    
                    Picker("When to take", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { freq in
                            Text(freq).tag(freq)
                        }
                    }
                }
                
                Section(header: Text("Reminder Time ⏰")) {
                    Toggle("Enable Reminder", isOn: $enableReminder)
                    
                    if enableReminder {
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Button(action: {
                                    hour = hour > 1 ? hour - 1 : 12
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color("AccentPink"))
                                }
                                .buttonStyle(.borderless)
                                
                                Text(String(format: "%02d", hour))
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 30)
                                    .background(Color("AccentCoral"))
                                    .cornerRadius(8)
                                
                                Button(action: {
                                    hour = hour < 12 ? hour + 1 : 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(Color("AccentPink"))
                                }
                                .buttonStyle(.borderless)
                            }
                            
                            HStack(spacing: 4) {
                                Button(action: {
                                    minute = minute > 0 ? minute - 1 : 59
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color("AccentPink"))
                                }
                                .buttonStyle(.borderless)
                                
                                Text(String(format: "%02d", minute))
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 30)
                                    .background(Color("AccentCoral"))
                                    .cornerRadius(8)
                                
                                Button(action: {
                                    minute = minute < 59 ? minute + 1 : 0
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(Color("AccentPink"))
                                }
                                .buttonStyle(.borderless)
                            }
                            
                            Button(action: {
                                isAM.toggle()
                            }) {
                                Text(isAM ? "AM" : "PM")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 30)
                                    .background(Color("AccentCoral"))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.borderless)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle(medicationToEdit == nil ? "Add Medication" : "Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMedication()
                    }
                    .disabled(medicationName.isEmpty || dosage.isEmpty)
                }
            }
        }
    }
    
    private func saveMedication() {
        let actualHour = isAM ? hour % 12 : (hour % 12) + 12
        let timeString = String(format: "%02d:%02d", actualHour, minute)
        
        if let existing = medicationToEdit {
            viewModel.updateMedication(
                medicationId: existing.id!,
                name: medicationName,
                dosage: dosage,
                frequency: frequency,
                reminderTimes: enableReminder ? [timeString] : []
            )
        } else {
            viewModel.addMedication(
                name: medicationName,
                dosage: dosage,
                frequency: frequency,
                reminderTimes: enableReminder ? [timeString] : []
            )
        }
        
        dismiss()
    }
}
