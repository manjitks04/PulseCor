//
//  CheckedIn.swift
//  PulseCor
//
//
import SwiftUI

struct AlreadyCheckedInView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color("AccentCoral"), Color("AccentPink")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("You're all set! 🎉")
                    .font(.appHeroTitle)
                    .foregroundColor(Color("MainText"))
                
                Text("You've already checked in today.\nCome back tomorrow to continue your streak!")
                    .font(.appBodyLarge)
                    .foregroundColor(Color("MainText").opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Got it!")
                    .font(.appSubtitleSemibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(LinearGradient(colors: [Color("AccentCoral"), Color("AccentPink")], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("MainBG"))
        .navigationTitle("Check-in")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
   NavigationStack {
       AlreadyCheckedInView()
   }
}
