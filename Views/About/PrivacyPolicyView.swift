//
//  PrivacyPolicyView.swift
//  PulseCor
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                PolicyCard(title: "1. Overview", content: "PulseCor is a personal cardiovascular wellness application developed as part of an academic project at the University of Westminster. We are committed to protecting your privacy. This policy explains what data we collect, how it is used, and your rights as a user.")

                PolicyCard(title: "2. Data We Collect", content: "PulseCor collects only the information you choose to provide through the app: your name and profile information; daily check-in responses including sleep quality, sleep duration, water intake, stress level, energy level, and physical activity; medication reminders you set within the app; and streak and points data.\n\nIf you choose to connect Apple HealthKit, we may also access: step count, heart rate, resting heart rate, and heart rate variability (HRV). HealthKit access is entirely optional and can be revoked at any time via your iPhone's Health app settings.")

                PolicyCard(title: "3. How Your Data Is Stored", content: "All data collected by PulseCor is stored locally on your device using Apple's SwiftData framework. We do not operate any servers. We do not transmit your personal or health data to any external service, cloud platform, or third party.\n\nYour data exists solely on your device and is deleted automatically if you uninstall the app.")

                PolicyCard(title: "4. How We Use Your Data", content: "Your data is used exclusively to personalise your in-app experience with Cora, our wellness companion; generate weekly insights based on your check-in history; track your streaks and progress; and display health metrics from Apple HealthKit where applicable.\n\nNo data is used for advertising, marketing, or profiling of any kind.")

                PolicyCard(title: "5. Third-Party Sharing", content: "We do not sell, rent, share, or disclose your personal or health data to any third party. Ever. PulseCor has no advertising partners, no analytics services, and no external data processors.")

                PolicyCard(title: "6. Research Use", content: "PulseCor was developed as part of a final-year computer science dissertation at the University of Westminster. A small group of volunteer participants may use the app as part of a short research study. Any data collected during this study remains entirely on participants' own devices and is not accessible by the researcher. Participation is voluntary, and participants may withdraw at any time by uninstalling the app.")

                PolicyCard(title: "7. Children's Privacy", content: "PulseCor is not intended for use by individuals under the age of 13. We do not knowingly collect data from children.")

                PolicyCard(title: "8. Your Rights", content: "Since all data is stored locally on your device, you retain full control at all times. You can delete your profile and all data by uninstalling the app, revoke HealthKit permissions at any time via the Health app, or reset your check-in history within the app settings.")

                PolicyCard(title: "9. Changes to This Policy", content: "We may update this policy as the app evolves. Any changes will be reflected within the app. Continued use of PulseCor following an update constitutes acceptance of the revised policy.")

                PolicyCard(title: "10. Contact", content: "For any questions regarding this privacy policy, please contact the developer Manjit Somal.")

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
        .navigationTitle("Privacy Policy")
        .toolbarBackground(Color("MainBG"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
