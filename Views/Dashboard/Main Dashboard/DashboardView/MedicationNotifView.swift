//
//  MedicationNotifView.swift
//  PulseCor
//
//
import SwiftUI
import SwiftData

struct MedicationAlertSheet: View {
    let medicationName: String
    let dosage: String
    let scheduledTime: String
    let onTaken: () -> Void
    let onSkip: () -> Void
    let onSnooze: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            HStack(spacing: 14) {
                Image("PillFill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .padding(10)
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(medicationName)
                        .font(.appSubtitleSemibold)
                        .foregroundColor(Color("MainText"))
                    
                    Text("Dosage: \(dosage)")
                        .font(.appCardTitle) // 14
                        .foregroundColor(.secondary)
                    
                    Text("Scheduled for \(scheduledTime)")
                        .font(.appSmallBodyMedium)
                        .foregroundColor(Color("AccentCoral"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color("AccentCoral").opacity(0.1))
                        .cornerRadius(20)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Divider()
                .padding(.vertical, 20)
            
            HStack {
                Text("WHAT WOULD YOU LIKE TO DO?")
                    .font(.appSmallBodyBold)
                    .foregroundColor(.secondary)
                    .kerning(0.8)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                MedicationActionButton(title: "Taken", background: AnyView(
                    LinearGradient(colors: [Color("AccentCoral"), Color("AccentPink")],
                                   startPoint: .leading, endPoint: .trailing)
                ), foregroundColor: .white, action: onTaken)
                
                MedicationActionButton(title: "Skip", background: AnyView(
                    Color(.systemGray6)
                ), foregroundColor: Color("MainText"), action: onSkip)
                
                MedicationActionButton(title: "Remind me later", background: AnyView(
                    Color.orange.opacity(0.12)
                ), foregroundColor: .orange, action: onSnooze)
                
                MedicationActionButton(title: "Dismiss", background: AnyView(
                    Color.blue.opacity(0.10)
                ), foregroundColor: .blue, action: onDismiss)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground))
        .cornerRadius(28)
    }
}

private struct MedicationActionButton: View {
    let title: String
    let background: AnyView
    let foregroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appCardTitleSemibold)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(background)
                .cornerRadius(18)
        }
    }
}
