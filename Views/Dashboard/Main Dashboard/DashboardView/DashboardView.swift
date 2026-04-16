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

    // Adaptive Layout Constants
    private let horizontalPadding: CGFloat = 20
    private let cardCornerRadius: CGFloat = 24

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
                VStack(spacing: 24) {
                    
                    //Header & Profile
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 4) {
                          Text("Hi there, \(users.first?.name ?? "Partner")👋")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("MainText"))
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        if let currentUser = users.first {
                            ProfileButton(user: currentUser)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 20)

                    // Main Check-in Card (The "Hero" Card)
                    VStack(spacing: 20) {
                        Text(monthYear)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))

                        // Weekly Calendar Row
                        HStack(spacing: 0) {
                            ForEach(weekDays) { day in
                                Button(action: { activeSheet = .calendar }) {
                                    VStack(spacing: 6) {
                                        Text(day.dayLetter)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                        
                                        Text("\(day.dayNum)")
                                            .font(.system(size: 14, weight: day.isCurrentDay ? .bold : .medium))
                                            .frame(width: 32, height: 32)
                                            .background(
                                                Circle()
                                                    .fill(day.isCurrentDay ? Color("FillBlue") : Color.clear)
                                            )
                                    }
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        VStack(spacing: 12) {
                            Text("Ready to check in...?")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            NavigationLink(destination: destinationView()) {
                                Text("Let's go!")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("AccentPink"))
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 12)
                                    .background(Capsule().fill(.white))
                                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                            }
                        }
                    }
                    .padding(.vertical, 24)
                    .background(LinearGradient(colors: [Color("AccentCoral"), Color("AccentPink").opacity(0.65)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(cardCornerRadius)
                    .padding(.horizontal, horizontalPadding)

                    //Stats Grid
                    HStack(spacing: 16) {
                        WeeklyCheckIn(completedDays: weeklyCheckInCount)
                        StreakCard(currentStreak: currentStreak)
                    }
                    .padding(.horizontal, horizontalPadding)

                    //Featured Articles
                    VStack(alignment: .leading, spacing: 16) {
                        Text("For you today")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("MainText"))
                            .padding(.horizontal, horizontalPadding)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(featuredArticles) { article in
                                    DashboardArticleCard(article: article)
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                        }
                    }
                    
                    Spacer(minLength: 30)
                }
            }
            .background(Color("MainBG").ignoresSafeArea())
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

// Article Card Component
struct DashboardArticleCard: View {
    let article: Article

    var body: some View {
        NavigationLink(destination: ArticleDetailView(article: article)) {
            ZStack(alignment: .bottomLeading) {
                if let imageName = article.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 180)
                        .clipped()
                } else {
                    Color.gray.opacity(0.2)
                        .frame(width: 140, height: 180)
                }
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                Text(article.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(12)
            }
            .frame(width: 140, height: 180)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//Onboarding Adapter
private struct DashboardOnboardingAdapter: View {
    @ObservedObject private var onboarding = OnboardingViewModel.shared
    @Binding var activeSheet: DashboardSheet?

    var body: some View {
        Color.clear
            .onChange(of: onboarding.shouldOpenSettings) { _, shouldOpen in
                if shouldOpen {
                    activeSheet = .settings
                } else if case .settings = activeSheet {
                    activeSheet = nil
                }
            }
    }
}
