//
//  MedicationCardView.swift
//  PulseCor
//
import Foundation
import SwiftUI

struct MedicationCard: View {
    let medication: Medication
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image("PillFill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding(8)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5)

            VStack(alignment: .leading, spacing: 4) {
                Text("1 pill, \(medication.frequency)")
                    .font(.caption)
                    .foregroundColor(Color("MainText").opacity(0.7))

                Text("\(medication.name), \(medication.dosage)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TextBlue"))

                if !medication.reminderTimes.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "clock").font(.caption)
                        Text(formatTime(medication.reminderTimes.first ?? ""))
                            .font(.subheadline)
                            .foregroundColor(Color("MainText"))
                    }
                }
            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.appTitle2)
                    .foregroundColor(Color("TextBlue"))
            }
        }
        .padding()
        .background(Color("CardBG"))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }

    private func formatTime(_ time: String) -> String {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else { return time }
        return String(format: "%02d:%02d", hour, minute)
    }
}
