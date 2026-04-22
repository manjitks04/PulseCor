//
//  MedicationCardView.swift
//  PulseCor
//
//  Displays single medication card with reminder times in Settings
//  Uses FlowLayout to wrap reminder time pills naturally
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
                    // Shows all reminder times as a wrapping row of pills
                    FlowLayout(spacing: 6) {
                        ForEach(medication.reminderTimes, id: \.self) { time in
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption2)
                                Text(formatTime(time))
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(Color("AccentCoral"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color("AccentCoral").opacity(0.1))
                            .cornerRadius(12)
                        }
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

// Custom layout that wraps subviews to next line when they exceed container width
// Used to display medication reminder times as flowing pills
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
