//
//  AccessibilityStatementView.swift
//  PulseCor
//

import SwiftUI

struct AccessibilityStatementView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                PolicyCard(title: "1. Our Commitment", content: "PulseCor is committed to being accessible to as many people as possible, regardless of ability or how they access their device. We have designed the app with inclusivity in mind from the outset.")

                PolicyCard(title: "2. Accessibility Features", content: "PulseCor includes the following accessibility support:\n\nDynamic Type — all text within the app scales with your iOS font size preference, including large accessibility text sizes.\n\nVoiceOver — core screens and interactive elements are labelled for compatibility with Apple's VoiceOver screen reader.\n\nContrast — the app's colour palette has been designed with sufficient contrast between text and background elements.\n\nDark Mode — PulseCor fully supports both light and dark mode on iOS.\n\nMotion — the app avoids gratuitous animations; any motion-sensitive effects are kept minimal.")

                PolicyCard(title: "3. Known Limitations", content: "We acknowledge that accessibility is an ongoing process. Some complex health data visualisations may not be fully described for VoiceOver users.  The Cora chat interface uses timed message animations which may be affected by reduced motion settings.\n\nWe welcome feedback from users who experience any accessibility barriers.")

                PolicyCard(title: "4. iOS Accessibility Settings", content: "PulseCor works alongside your device's built-in iOS accessibility features. We encourage you to use whichever settings best suit your needs, including Display & Text Size settings for contrast and text weight, VoiceOver for screen reading, Spoken Content for read-aloud support, and Switch Control or AssistiveTouch for alternative navigation.")

                PolicyCard(title: "5. Feedback", content: "If you experience any difficulty using PulseCor or would like to request an accessibility improvement, please contact the developer, Manjit Somal. We take all accessibility feedback seriously and will endeavour to address issues in future updates.")

                PolicyCard(title: "6. Standards", content: "We aim to meet the Web Content Accessibility Guidelines (WCAG) 2.1 Level AA where applicable to native iOS applications, and to follow Apple's Human Interface Guidelines on accessibility best practice.")

                Text("Last updated: March 2026")
                    .font(.system(size: 11))
                    .foregroundColor(Color("MainText").opacity(0.4))
                    .padding(.top, 4)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)
        }
        .background(Color("MainBG"))
        .navigationTitle("Accessibility Statement")
        .toolbarBackground(Color("MainBG"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
