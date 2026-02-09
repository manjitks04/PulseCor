//
//  AboutView.swift
//  PulseCor
//
//  pulseCor disclaimers
//

import SwiftUI
import SwiftData

struct AboutView: View {
    @Query private var users: [User]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 20) {
                        Text("PulseCor")
                            .font(.system(size: 42, weight: .bold))
                            .padding(.top, 55)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color("AccentCoral"), Color("AccentPink")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        VStack(spacing: 8) {
                            Text("About Us")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("MainText"))

                            Text("We noticed something missing in the world of heart health apps; a middle ground. Most apps are either clinical-grade monitors that overwhelm you with medical jargon and anxiety, or basic fitness trackers that barely scratch the surface of cardiovascular wellness.\n\nWe built this app for real people who want to genuinely improve their heart health and understand how their daily choices make a difference, without the stress, the complexity, or the price tag of medical equipment.")
                                .font(.system(size: 12))
                                .foregroundColor(Color("MainText"))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(0.5)
                        }
                        .padding(14)
                        .background(Color("CardBG"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
                        
                        VStack(spacing: 8) {
                            Text("Our Mission")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("MainText"))

                            Text("We're here to make heart health simple, supportive, and sustainable. PulseCor was built for everyday people who want to understand how their lifestyle choices affect their wellbeing.\n\nWe believe that lasting health comes from small, consistent changes, not perfection. That's why we created Cora, your warm and empathetic companion who guides you through daily check-ins and celebrates your progress.")
                                .font(.system(size: 12))
                                .foregroundColor(Color("MainText"))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(0.5)
                        }
                        .padding(14)
                        .background(Color("CardBG"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                        
                        VStack(spacing: 6) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "shield.checkered")
                                    .font(.system(size: 40))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color("LightGreen"), Color("LightPurple").opacity(0.65)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .padding(.leading, 8)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Your data is protected")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color("AccentCoral"), Color("AccentPink")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    
                                    Text("We will never sell your data to third parties, or use it for advertising. You can delete it at anytime. We believe your health information belongs to you and you alone. No hidden agendas, no fine print surprises, just a straightforward promise: you can focus on your well-being with complete peace of mind.")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color("TextBlue"))
                                        .lineSpacing(1.5)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color("CardBG"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                          
                        VStack(spacing: 6) {
                            HStack(spacing: 8) {
                                NavigationLink(destination: PrivacyPolicyView()) {
                                    Text("Privacy Policy")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color("AccentCoral"))

                                }
                                
                                Circle()
                                    .fill(Color("AccentCoral"))
                                    .frame(width: 4, height: 4)
                                
                                NavigationLink(destination: TermsOfUseView()) {
                                    Text("Terms of Use")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color("AccentCoral"))
                                }
                            }
                            
                            NavigationLink(destination: AccessibilityStatementView()) {
                                Text("Accessibility statement")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color("AccentCoral"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)

                        Text("PulseCor")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(Color.gray.opacity(0.5))
                            .padding(.top, 2)
                        
                        Spacer(minLength: 16)
                    }
                    .padding(.horizontal, 14)
                    
                    if let currentUser = users.first {
                        ProfileButton(user: currentUser)
                            .padding(.trailing, 16)
                            .padding(.top, 20)
                    }
                }
            }
            .background(Color("MainBG"))
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    AboutView()
}
