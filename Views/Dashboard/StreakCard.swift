//
//  StreakCard.swift
//  PulseCor
//
//

//import SwiftUI
//
//struct StreakCard: View{
//    let currentStreak: Int
//    
//    var body: some View{
//        VStack(spacing: 6){
//            Text("\(currentStreak)")
//                .font(.system(size: 64, weight: .bold))
//                .foregroundColor(Color(red: 74/255, green: 85/255, blue: 104/255))
//
//            Text ("Day Streak")
//                .font(.title3)
//                .fontWeight(.medium)
//                .foregroundColor(Color(red: 74/255, green: 85/255, blue: 104/255))
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 120)
//        .padding(.vertical, 20)
//        .padding(.horizontal, 16)
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//        .overlay(
//                    RoundedRectangle(cornerRadius: 16)
//                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                )
//                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
//    }
//}
import SwiftUI

struct StreakCard: View {
    let currentStreak: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("LightGreen"))
                .frame(width: 120, height: 120)
                .offset(x: 70, y: -40)
            
            Circle()
                .fill(Color("LightGreen"))
                    .frame(width: 40, height: 40)
                    .offset(x: -55, y: 40)
            
            VStack(spacing: 6) {
                if currentStreak == 0 {
                    VStack(spacing: 8) {
                        Text("Start your journey with Cora today,\nyour streak will show here!")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextBlue"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                        
                        Text("🌟")
                            .font(.system(size: 24))
                    }
                } else {
                    VStack(spacing: 4) {
                        Text("\(currentStreak)")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(Color("MainText"))
                        
                        Text(currentStreak == 1 ? "Day" : "Days")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("SecondaryText"))
                        
                        //badges on different occasains
                        if currentStreak >= 7 {
                            HStack(spacing: 6) {
                                if currentStreak >= 7 {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                }
                                if currentStreak >= 30 {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                                if currentStreak >= 90 {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.purple)
                                }
                                if currentStreak >= 365 {
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .font(.caption)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(Color("CardBG"))
        .cornerRadius(20)
        .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color("AccentCoral"),
                                    Color("AccentPink"),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: Color("AccentPink").opacity(0.15), radius: 12, x: 0, y: 4)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
        }
