//
//  DailyStreakTracker.swift
//  PulseCor
//
import SwiftUI
import SwiftData

struct DailyStreakTracker: View {
    let currentDay: Int
    let rewards = [5, 5, 10, 10, 15, 15, 25]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily check in")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("MainText"))
                    
                    Text(currentDay >= 7 ?
                         "Congratulations for achieving a 7 day streak! Your badge will show on your profile!" :
                         "Achieve a 7 day streak to unlock a special badge!")
                        .font(.subheadline)
                        .foregroundColor(Color("MainText").opacity(0.7))
                }
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    DayCard(
                        day: day,
                        reward: rewards[day - 1],
                        isCompleted: day <= currentDay,
                        isCurrent: day == currentDay
                    )
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AccentCoral"), Color("AccentPink")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(min(currentDay, 7)) / 7, height: 4)
                }
                .cornerRadius(2)
            }
            .frame(height: 4)
            .padding(.horizontal, 4)
            
            HStack {
                HStack(spacing: 6) {
                    Text("Current streak: \(currentDay) day\(currentDay != 1 ? "s" : "")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("MainText"))
                }
                
                Spacer()
                
                let earnedPoints = rewards.prefix(min(currentDay, 7)).reduce(0, +)
                Text("\(earnedPoints)/\(rewards.reduce(0, +)) pts")
                    .font(.subheadline)
                    .foregroundColor(Color("MainText").opacity(0.6))
            }
        }
        .padding(20)
        .background(Color("CardBG"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

#Preview {
    DailyStreakTracker(currentDay: 7)
        .padding()
}
