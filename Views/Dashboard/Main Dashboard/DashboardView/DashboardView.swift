//
//  DashboardView.swift
//  PulseCor
//
//main home view
//
import SwiftUI
import SwiftData

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navManager: NavigationManager
    @State private var showMedicationAlert = false
    @Query private var users: [User]
    @State private var hasCheckedInToday = false
    @State private var isCheckingStatus = true
    @State private var showCalendar = false
    
    var weekDays: [CalendarDay] {
        WeeklyCalendarHelper.getCurrentWeek()
    }
    
    var monthYear: String {
        WeeklyCalendarHelper.getMonthYear()
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
                            
                            Button(action: { showCalendar = true }) {
                                HStack(spacing: 0) {
                                    ForEach(weekDays) { day in
                                        VStack(spacing: 3) {
                                            Text(day.dayLetter)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white.opacity(1))
                                            
                                            Text("\(day.dayNum)")
                                                .font(.system(size: 15, weight: day.isCurrentDay ? .bold : .regular))
                                                .foregroundColor(.white)
                                                .frame(width: 32, height: 28)
                                                .background(
                                                    Circle()
                                                        .fill(day.isCurrentDay ? Color("FillBlue") : Color.clear)
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
                                
                                if isCheckingStatus {
                                    ProgressView()
                                        .tint(.white)
                                } else {
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
                        
                        HStack(spacing: 16){
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
                    .onAppear {
                        checkTodayStatus()
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
                if users.isEmpty {
                    let tempUser = User(name: "Test")
                    modelContext.insert(tempUser)
                }
                
                viewModel.loadDashboardData()
            }
            .onChange(of: navManager.pendingMedication) { _, newValue in
                   if newValue != nil {
                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                           showMedicationAlert = true
                       }
                   }
            }
            .sheet(isPresented: $showMedicationAlert) {
                MedicationAlertSheet(
                    medicationName: navManager.pendingMedication?.name ?? "",
                    dosage: navManager.pendingMedication?.dosage ?? "",
                    scheduledTime: navManager.pendingMedication?.time ?? "",
                    onTaken: {
                        if let med = navManager.pendingMedication {
                            MedicationViewModel().logMedicationAction(medicationId: med.id, status: .taken, scheduledTime: med.time)
                        }
                        navManager.pendingMedication = nil
                        showMedicationAlert = false
                    },
                    onSkip: {
                        if let med = navManager.pendingMedication {
                            MedicationViewModel().logMedicationAction(medicationId: med.id, status: .skipped, scheduledTime: med.time)
                        }
                        navManager.pendingMedication = nil
                        showMedicationAlert = false
                    },
                    onSnooze: {
                        if let med = navManager.pendingMedication {
                            NotificationService.shared.snoozeMedicationReminder(medicationId: med.id, medicationName: med.name, dosage: med.dosage)
                            MedicationViewModel().logMedicationAction(medicationId: med.id, status: .snoozed, scheduledTime: med.time)
                        }
                        navManager.pendingMedication = nil
                        showMedicationAlert = false
                    },
                    onDismiss: {
                        navManager.pendingMedication = nil
                        showMedicationAlert = false
                    }
                )
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
            }
            .sheet(isPresented: $showCalendar) {
                CalendarView()
                    .presentationDetents([.large])
            }
        }
    }
    
    @ViewBuilder
    private func destinationView() -> some View {
        if hasCheckedInToday {
            AlreadyCheckedInView()
        } else {
            ConversationView()
        }
    }
    
    private func checkTodayStatus() {
        do {
            hasCheckedInToday = try DatabaseService.shared.hasCheckedInToday()
            isCheckingStatus = false
        } catch {
            print("Error checking today's status: \(error)")
            hasCheckedInToday = false
            isCheckingStatus = false
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
