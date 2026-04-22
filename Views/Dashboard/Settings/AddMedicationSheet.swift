//
//  AddMedicationSheet.swift
//  PulseCor
//
// Modal sheet for adding new medications or editing existing ones
//
import SwiftUI

struct AddMedicationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MedicationViewModel

    let medicationToEdit: Medication?

    @State private var medicationName: String
    @State private var dosage: String
    @State private var frequency: String
    @State private var enableReminder: Bool
    @State private var reminderTimes: [(hour: Int, minute: Int)]

    let frequencies = ["Before Breakfast", "After Breakfast", "Before Lunch", "After Lunch", "Before Dinner", "After Dinner", "Before Bed"]

    // Initialises sheet in either add or edit mode
    // If medicationToEdit is provided, pre-fills form with existing values
    // Parses reminderTimes from "HH:mm" string format to (hour, minute) tuples
    init(viewModel: MedicationViewModel, medicationToEdit: Medication? = nil) {
        self.viewModel = viewModel
        self.medicationToEdit = medicationToEdit

        if let medication = medicationToEdit {
            _medicationName = State(initialValue: medication.name)
            _dosage = State(initialValue: medication.dosage)
            _frequency = State(initialValue: medication.frequency)
            _enableReminder = State(initialValue: !medication.reminderTimes.isEmpty)

            let parsed: [(hour: Int, minute: Int)] = medication.reminderTimes.compactMap { timeString in
                let parts = timeString.split(separator: ":")
                guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { return nil }
                return (hour: h, minute: m)
            }
            _reminderTimes = State(initialValue: parsed.isEmpty ? [(hour: 9, minute: 0)] : parsed)
        } else {
            _medicationName = State(initialValue: "")
            _dosage = State(initialValue: "")
            _frequency = State(initialValue: "After Breakfast")
            _enableReminder = State(initialValue: true)
            _reminderTimes = State(initialValue: [(hour: 9, minute: 0)])
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

                Section(header: Text("Reminder Times ⏰")) {
                    Toggle("Enable Reminders", isOn: $enableReminder)

                    if enableReminder {
                        ForEach(reminderTimes.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Reminder \(index + 1)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                MedTimePickerRow(
                                    hour: Binding(
                                        get: { reminderTimes[index].hour },
                                        set: { reminderTimes[index].hour = $0 }
                                    ),
                                    minute: Binding(
                                        get: { reminderTimes[index].minute },
                                        set: { reminderTimes[index].minute = $0 }
                                    )
                                )
                            }
                            .padding(.vertical, 4)
                        }
                        // Swipe left on any row to delete it.
                        // Disabled on the last remaining row so there's always one time.
                        .onDelete { indexSet in
                            guard reminderTimes.count > 1 else { return }
                            reminderTimes.remove(atOffsets: indexSet)
                        }

                        Button(action: {
                            let last = reminderTimes.last ?? (hour: 9, minute: 0)
                            reminderTimes.append((hour: (last.hour + 1) % 24, minute: last.minute))
                        }) {
                            Label("Add Another Time", systemImage: "plus.circle.fill")
                                .foregroundColor(Color("AccentCoral"))
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .navigationTitle(medicationToEdit == nil ? "Add Medication" : "Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveMedication() }
                        .disabled(medicationName.isEmpty || dosage.isEmpty)
                }
            }
        }
    }

    // Converts reminder times to "HH:mm" format and calls appropriate ViewModel method
    // Creates new medication or updates existing one based on medicationToEdit state
    private func saveMedication() {
        let times: [String] = enableReminder
            ? reminderTimes.map { String(format: "%02d:%02d", $0.hour, $0.minute) }
            : []

        if let existing = medicationToEdit {
            viewModel.updateMedication(
                existing,
                name: medicationName,
                dosage: dosage,
                frequency: frequency,
                reminderTimes: times
            )
        } else {
            viewModel.addMedication(
                name: medicationName,
                dosage: dosage,
                frequency: frequency,
                reminderTimes: times
            )
        }

        dismiss()
    }
}

private struct MedTimePickerRow: View {
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        HStack(spacing: 8) {
            Spacer()

            HStack(spacing: 4) {
                Button(action: { hour = hour > 0 ? hour - 1 : 23 }) {
                    Image(systemName: "minus.circle.fill").foregroundColor(Color("AccentPink"))
                }
                .buttonStyle(.borderless)

                Text(String(format: "%02d", hour))
                    .font(.body).fontWeight(.semibold).foregroundColor(.white)
                    .frame(width: 40, height: 30)
                    .background(Color("AccentCoral")).cornerRadius(8)

                Button(action: { hour = hour < 23 ? hour + 1 : 0 }) {
                    Image(systemName: "plus.circle.fill").foregroundColor(Color("AccentPink"))
                }
                .buttonStyle(.borderless)
            }

            Text(":").font(.body).fontWeight(.semibold)

            HStack(spacing: 4) {
                Button(action: { minute = minute > 0 ? minute - 1 : 59 }) {
                    Image(systemName: "minus.circle.fill").foregroundColor(Color("AccentPink"))
                }
                .buttonStyle(.borderless)

                Text(String(format: "%02d", minute))
                    .font(.body).fontWeight(.semibold).foregroundColor(.white)
                    .frame(width: 40, height: 30)
                    .background(Color("AccentCoral")).cornerRadius(8)

                Button(action: { minute = minute < 59 ? minute + 1 : 0 }) {
                    Image(systemName: "plus.circle.fill").foregroundColor(Color("AccentPink"))
                }
                .buttonStyle(.borderless)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
