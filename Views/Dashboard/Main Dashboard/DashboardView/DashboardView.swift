//
//  DashboardView.swift
//  PulseCor
//
import SwiftUI
import SwiftData

enum DashboardSheet: Identifiable {
    case medication(PendingMedication)
    case calendar

    var id: String {
        switch self {
        case .medication(let med): return "medication-\(med.id)"
        case .calendar: return "calendar"
        }
    }
}

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navManager: NavigationManager
    @StateObject private var viewModel = DashboardViewModel()
    @State private var activeSheet: DashboardSheet?

    @Query private var users: [User]
    @Query private var todaysCheckIns: [DailyCheckIn]

    private var hasCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return todaysCheckIns.contains {
            $0.isComplete && Calendar.current.startOfDay(for: $0.date) == today
        }
    }

    var weekDays: [CalendarDay] { WeeklyCalendarHelper.getCurrentWeek() }
    var monthYear: String { WeeklyCalendarHelper.getMonthYear() }

    init() {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        _todaysCheckIns = Query(filter: #Predicate<DailyCheckIn> {
            $0.date >= start && $0.date < end
        })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Hi there, \(users.first?.name ?? "Partner")👋")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("MainText"))
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 55)

                        VStack(spacing: 16) {
                            Text(monthYear)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Button(action: { activeSheet = .calendar }) {
                                HStack(spacing: 0) {
                                    ForEach(weekDays) { day in
                                        VStack(spacing: 3) {
                                            Text(day.dayLetter)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)

                                            Text("\(day.dayNum)")
                                                .font(.system(size: 15, weight: day.isCurrentDay ? .bold : .regular))
                                                .foregroundColor(.white)
                                                .frame(width: 32, height: 28)
                                                .background(
                                                    Circle().fill(day.isCurrentDay ? Color("FillBlue") : Color.clear)
                                                )
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .buttonStyle(.plain)

                            VStack(spacing: 8) {
                                Text("Ready to check in...?")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)

                                NavigationLink(destination: destinationView()) {
                                    Text("Let's go!")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.pink)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 8)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color("AccentCoral"), Color("AccentPink").opacity(0.65)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .padding(.horizontal)

                        HStack(spacing: 16) {
                            WeeklyCheckIn(completedDays: viewModel.weeklyCheckInCount)
                            StreakCard(currentStreak: viewModel.currentStreak)
                        }
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("For you today")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color("MainText"))
                                .padding(.horizontal)

                            HStack(spacing: 8) {
                                ForEach(viewModel.featuredArticles) { article in
                                    DashboardArticleCard(article: article)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    if let currentUser = users.first {
                        ProfileButton(user: currentUser)
                            .padding(.trailing, 16)
                            .padding(.top, 20)
                    }
                }
            }
            .background(Color("MainBG"))
            .navigationBarHidden(true)
            .task {
                viewModel.setContext(modelContext)
                if users.isEmpty {
                    modelContext.insert(User(name: "Test"))
                }
            }
            .onAppear {
                if let med = navManager.pendingMedication {
                    activeSheet = .medication(med)
                }
            }
            .onChange(of: navManager.pendingMedication) { _, newValue in
                if let med = newValue {
                    activeSheet = .medication(med)
                }
            }
            // Single sheet handles both cases — no conflicts, no race conditions
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .medication(let med):
                    MedicationAlertSheet(
                        medicationName: med.name,
                        dosage: med.dosage,
                        scheduledTime: med.time,
                        onTaken: { logMedication(med: med, status: .taken) },
                        onSkip: { logMedication(med: med, status: .skipped) },
                        onSnooze: {
                            NotificationService.shared.snoozeMedicationReminder(
                                medicationId: med.id,
                                medicationName: med.name,
                                dosage: med.dosage
                            )
                            logMedication(med: med, status: .snoozed)
                        },
                        onDismiss: {
                            navManager.pendingMedication = nil
                            activeSheet = nil
                        }
                    )
                    .presentationDetents([.height(300)])
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled(true)

                case .calendar:
                    CalendarView()
                        .presentationDetents([.large])
                }
            }
        }
    }

    private func logMedication(med: PendingMedication, status: MedicationStatus) {
        let log = MedicationLog(
            medicationLocalId: UUID(uuidString: med.id) ?? UUID(),
            medicationName: med.name,
            medicationDosage: med.dosage,
            status: status,
            scheduledTime: med.time
        )
        modelContext.insert(log)
        try? modelContext.save()
        navManager.pendingMedication = nil
        activeSheet = nil
    }

    @ViewBuilder
    private func destinationView() -> some View {
        if hasCheckedInToday {
            AlreadyCheckedInView()
        } else {
            ConversationView()
        }
    }
}

struct DashboardArticleCard: View {
    let article: Article

    var body: some View {
        NavigationLink(destination: ArticleDetailView(article: article)) {
            ZStack(alignment: .bottomLeading) {
                if let imageName = article.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 130, height: 200)
                        .clipped()
                } else {
                    Color.gray.opacity(0.3)
                        .frame(width: 130, height: 200)
                }

                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                    startPoint: .center,
                    endPoint: .bottom
                )

                Text(article.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .padding(12)
            }
            .frame(width: 130, height: 200)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
