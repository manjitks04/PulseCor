//
//  DashboardView.swift
//  PulseCor
//
import SwiftUI
import SwiftData

enum DashboardSheet: Identifiable {
    case medication(PendingMedication)
    case calendar
    case settings

    var id: String {
        switch self {
        case .medication(let med): return "medication-\(med.id)-\(med.time)"
        case .calendar: return "calendar"
        case .settings: return "settings"
        }
    }
}

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navManager: NavigationManager
    @StateObject private var viewModel = DashboardViewModel()
    @State private var activeSheet: DashboardSheet?
    @State private var featuredArticles: [Article] = []

    @Query private var users: [User]

    @Query(filter: #Predicate<DailyCheckIn> { $0.isComplete == true })
    private var allCheckIns: [DailyCheckIn]

    @Query(filter: #Predicate<Article> { $0.showOnBrowse == true })
    private var browseArticles: [Article]

    var weekDays: [CalendarDay] { WeeklyCalendarHelper.getCurrentWeek() }
    var monthYear: String { WeeklyCalendarHelper.getMonthYear() }

    private var currentStreak: Int { users.first?.currentStreak ?? 0 }

    private var weeklyCheckInCount: Int {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return 0 }
        return allCheckIns.filter { $0.date >= weekStart }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    HStack {
                        Text("Hi there, \(users.first?.name ?? "Partner")👋")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("MainText"))
                        Spacer()
                    }
                    .padding(.horizontal, 40)
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
                                            .background(Circle().fill(day.isCurrentDay ? Color("FillBlue") : Color.clear))
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
                    .background(LinearGradient(colors: [Color("AccentCoral"), Color("AccentPink").opacity(0.65)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
                    .padding(.horizontal, 40)

                    HStack(spacing: 16) {
                        WeeklyCheckIn(completedDays: weeklyCheckInCount)
                        StreakCard(currentStreak: currentStreak)
                    }
                    .padding(.horizontal, 40)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("For you today")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color("MainText"))
                            .padding(.horizontal, 40)

                        HStack(spacing: 8) {
                            ForEach(featuredArticles) { article in
                                DashboardArticleCard(article: article)
                            }
                        }
                        .padding(.horizontal, 50)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if let currentUser = users.first {
                        ProfileButton(user: currentUser)
                            .padding(.trailing, 45)
                            .padding(.top, 20)
                    }
                }
            }
            .background(Color("MainBG"))
            .navigationBarHidden(true)
            .background(DashboardOnboardingAdapter(activeSheet: $activeSheet))
            .task {
                viewModel.setContext(modelContext)
                if users.isEmpty {
                    let profilePics = (1...10).map { "PFP \($0)" }
                    modelContext.insert(User(name: "Test", profilePic: profilePics.randomElement() ?? "PFP 1"))
                }
            }
            .onAppear {
                if featuredArticles.isEmpty {
                    featuredArticles = Array(browseArticles.shuffled().prefix(3))
                }
                viewModel.loadDashboardData()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                navManager.restorePendingMedicationIfNeeded()
                showMedicationIfPending()
                viewModel.loadDashboardData()
            }
            .onReceive(navManager.$pendingMedication) { med in
                if med != nil { showMedicationIfPending() }
            }
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
                            NotificationService.shared.snoozeMedicationReminder(medicationId: med.id, medicationName: med.name, dosage: med.dosage)
                            logMedication(med: med, status: .snoozed)
                        },
                        onDismiss: { dismissMedicationSheet() }
                    )
                    .presentationDetents([.height(300)])
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled(true)

                case .calendar:
                    CalendarView()
                        .presentationDetents([.large])

                case .settings:
                    SettingsView()
                        .presentationDetents([.large])
                }
            }
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        if viewModel.hasCheckedInToday {
            AlreadyCheckedInView()
        } else {
            ConversationView()
        }
    }

    private func showMedicationIfPending() {
        guard let med = navManager.pendingMedication else { return }
        if case .medication(let current) = activeSheet, current == med { return }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            activeSheet = .medication(med)
        }
    }

    private func dismissMedicationSheet() {
        navManager.pendingMedication = nil
        activeSheet = nil
    }

    private func logMedication(med: PendingMedication, status: MedicationStatus) {
        viewModel.logMedicationAction(med: med, status: status)
        dismissMedicationSheet()
    }
}

private struct DashboardOnboardingAdapter: View {
    @ObservedObject private var onboarding = OnboardingViewModel.shared
    @Binding var activeSheet: DashboardSheet?

    var body: some View {
        Color.clear
            .onChange(of: onboarding.shouldOpenSettings) { _, shouldOpen in
                if shouldOpen {
                    activeSheet = .settings
                } else {
                    if case .settings = activeSheet {
                        activeSheet = nil
                    }
                }
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
                        .frame(width: 110, height: 160)
                        .clipped()
                } else {
                    Color.gray.opacity(0.3).frame(width: 130, height: 180)
                }
                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .center, endPoint: .bottom)
                Text(article.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .padding(12)
            }
            .frame(width: 110, height: 160)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

