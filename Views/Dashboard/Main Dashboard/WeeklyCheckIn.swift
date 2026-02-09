//
//  WeeklyCheckIn.swift
//  PulseCor
//
//

import SwiftUI

struct WeeklyCheckIn: View {
    
    let completedDays: Int
    let totalDays: Int = 7
    
    private var fullStars: Int {
        if completedDays == 7{
            return 4
        }
        return completedDays / 2
    }
    
    private var halfStars: Bool {
        if completedDays == 7{
            return false
        }
        return completedDays % 2 == 1
    }
    
    @ViewBuilder
    private func starImage(at index: Int) -> some View {
        if index < fullStars {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
        } else if index == fullStars && halfStars {
            Image(systemName: "star.leadinghalf.filled")
                .foregroundStyle(.yellow)
        } else {
            Image(systemName: "star")
                .foregroundStyle(.gray.opacity(0.3))
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("LightPurple"))
                .frame(width: 120, height: 120)
                .offset(x: -60, y: 30)

            
            VStack(alignment: .center,spacing: 6){
                Text("This week")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TextBlue"))

                Text ("\(completedDays) / \(totalDays) day check in's")
                    .font(.subheadline)
                    .foregroundColor(Color("MainText"))
                
                HStack(spacing: 3){
                    ForEach(0..<4, id: \.self) {index in
                        starImage(at: index)
                            .font(.system(size: 28))
                    }
                }
                .padding(.top, 4)
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
                .shadow(color: Color("AccentCoral").opacity(0.15), radius: 12, x: 0, y: 4)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
        }
        
    
