//
//  DayCard.swift
//  PulseCor
//
//
import SwiftUI
import SwiftData


struct DayCard: View {
    let day: Int
    let reward: Int
    let isCompleted: Bool
    let isCurrent: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isCompleted ?
                          LinearGradient(
                            colors: [Color("AccentCoral"), Color("AccentPink")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ) : LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ))
                    .frame(width: 44, height: 44)
                
                if day == 7 {
                    Text(isCompleted ? "👑" : "🎁")
                        .font(.title3)
                } else if isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                } else {
                    Text("\(reward)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            .scaleEffect(isCurrent ? 1.1 : 1.0)
            .animation(.spring(response: 0.3), value: isCurrent)
            
            Text("Day\(day)")
                .font(.caption)
                .fontWeight(isCompleted ? .semibold : .regular)
                .foregroundColor(isCompleted ? Color("MainText") : Color.gray)
        }
    }
}
