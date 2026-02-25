//
//  DayDetailView.swift
//  PulseCor
//
import SwiftUI

struct DayDetailView: View {
    let dayStatus: DayStatus

    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: dayStatus.date).uppercased()
    }

    private var formattedDate: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: dayStatus.date)
        let suffix = WeeklyCalendarHelper.getDaySuffix(for: day)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return "\(day)\(suffix) \(formatter.string(from: dayStatus.date))"
    }

    private var medsTakenCount: Int {
        dayStatus.medicationLogs.filter { $0.status == .taken }.count
    }

    private var medicationEntries: [(name: String, dosage: String, status: MedicationStatus)] {
        dayStatus.medicationLogs
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color("MainBG").ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AccentPink").opacity(0.12), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 80, y: -60)
                .allowsHitTesting(false)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    summaryPills
                    checkInSection
                    if !medicationEntries.isEmpty {
                        Divider()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        medicationSection
                    }
                    Spacer().frame(height: 32)
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(dayOfWeek)
                .font(.appSmallBodyBold)
                .kerning(1.2)
                .foregroundColor(Color("AccentCoral"))

            Text(formattedDate)
                .font(.appHeroTitle)
                .foregroundColor(Color("MainText"))
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 20)
    }

    private var summaryPills: some View {
        HStack(spacing: 8) {
            if dayStatus.hasCheckIn {
                DaySummaryPill(text: "Checked in", dotColor: Color("AccentPink"))
            }
            if !medicationEntries.isEmpty {
                DaySummaryPill(
                    text: "\(medsTakenCount)/\(medicationEntries.count) meds taken",
                    dotColor: Color("AccentCoral")
                )
            }
            if !dayStatus.hasCheckIn && medicationEntries.isEmpty {
                DaySummaryPill(text: "No activity", dotColor: Color(.systemGray3))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
    }

    private var checkInSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            DaySectionLabel(text: "Daily Check-In")

            DayEntryCard(
                icon: "🌸",
                iconColors: (Color("AccentPink").opacity(0.3), Color("AccentCoral").opacity(0.2)),
                iconBorder: Color("AccentPink").opacity(0.25),
                title: dayStatus.hasCheckIn ? "Checked in with Cora" : "No check-in recorded",
                subtitle: dayStatus.hasCheckIn ? "Daily check-in complete" : "You didn't check in this day",
                badge: DayEntryCard.BadgeStyle(
                    text: dayStatus.hasCheckIn ? "Done" : "Missed",
                    foreground: dayStatus.hasCheckIn ? Color("AccentPink") : Color(.systemGray2),
                    background: dayStatus.hasCheckIn ? Color("AccentPink").opacity(0.15) : Color(.systemGray6),
                    border: dayStatus.hasCheckIn ? Color("AccentPink").opacity(0.25) : Color(.systemGray4).opacity(0.3)
                )
            )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var medicationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            DaySectionLabel(text: "Medications")

            ForEach(medicationEntries.indices, id: \.self) { i in
                let entry = medicationEntries[i]
                DayEntryCard(
                    icon: "💊",
                    iconColors: entry.status.iconColors,
                    iconBorder: entry.status.iconBorder,
                    title: entry.name,
                    subtitle: entry.dosage,
                    badge: entry.status.badge
                )
            }
        }
        .padding(.horizontal, 16)
    }
}
