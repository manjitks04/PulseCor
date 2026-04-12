////
////  ChatView.swift
////  PulseCor
////
//import SwiftUI
//import SwiftData
//
//struct ChatView: View {
//    @Query private var users: [User]
//
//    @Query(filter: #Predicate<DailyCheckIn> { $0.isComplete == true },
//           sort: \DailyCheckIn.date, order: .reverse)
//    private var checkIns: [DailyCheckIn]
//
//    @StateObject private var cardViewModel = CoraCardViewModel()
//    @ObservedObject private var navManager = NavigationManager.shared
//    @State private var showingReflection = false
//
//    private var hasCheckedInToday: Bool {
//        let today = Calendar.current.startOfDay(for: Date())
//        return checkIns.first.map {
//            Calendar.current.startOfDay(for: $0.date) == today
//        } ?? false
//    }
//
//    private var currentStreak: Int {
//        users.first?.currentStreak ?? 0
//    }
//
//    var body: some View {
//        NavigationStack {
//            ZStack(alignment: .topTrailing) {
//                Color("MainBG").ignoresSafeArea()
//
//                ScrollViewReader { proxy in
//                    ScrollView(showsIndicators: false) {
//                        VStack(spacing: 16) {
//                            HeroCheckInCard(
//                                userName: users.first?.name ?? "there",
//                                hasCheckedInToday: hasCheckedInToday
//                            )
//                            DailyStreakTracker(currentDay: currentStreak)
//                            CoraCardView(
//                                cardType: cardViewModel.cardType,
//                                onViewReflection: { showingReflection = true }
//                            )
//                            .id("cora-card")
//                            ChatOnboardingSpacerAdapter()
//                        }
//                        .padding(.top, 85)
//                        .padding(.bottom, 120)
//                    }
//                    
//                    .background(ChatOnboardingScrollAdapter(proxy: proxy))
//                    .onAppear { cardViewModel.load(checkIns: checkIns) }
//                    .onChange(of: checkIns.count) { cardViewModel.load(checkIns: checkIns) }
//                    .onReceive(navManager.$pendingWeeklyReflection) { pending in
//                        if pending {
//                            let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
//                            let recentCount = checkIns.filter { $0.date >= cutoff }.count
//                            if recentCount >= 4 { showingReflection = true }
//                            NavigationManager.shared.pendingWeeklyReflection = false
//                        }
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//            .fullScreenCover(isPresented: $showingReflection) {
//                WeeklyReflectionView(userStreak: currentStreak)
//            }
//        }
//    }
//}
//
//private struct ChatOnboardingSpacerAdapter: View {
//    @ObservedObject private var onboarding = OnboardingViewModel.shared
//
//    var body: some View {
//        if onboarding.isActive {
//            Color.clear.frame(height: 300)
//        } else {
//            EmptyView()
//        }
//    }
//}
//
//private struct ChatOnboardingScrollAdapter: View {
//    @ObservedObject private var onboarding = OnboardingViewModel.shared
//    let proxy: ScrollViewProxy
//
//    var body: some View {
//        Color.clear
//            .onChange(of: onboarding.currentStep) { _, step in
//                if step == .coraCard {
//                    withAnimation { proxy.scrollTo("cora-card", anchor: .top) }
//                }
//            }
//    }
//}
//
//
//  ChatView.swift
//  PulseCor
//
import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<DailyCheckIn> { $0.isComplete == true },
           sort: \DailyCheckIn.date, order: .reverse)
    private var checkIns: [DailyCheckIn]

    @Query private var users: [User]

    @StateObject private var viewModel = ChatScreenViewModel()
    @ObservedObject private var navManager = NavigationManager.shared

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Color("MainBG").ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            HeroCheckInCard(
                                userName: users.first?.name ?? "there",
                                hasCheckedInToday: viewModel.hasCheckedInToday
                            )
                            DailyStreakTracker(currentDay: viewModel.currentStreak)
                            CoraCardView(
                                cardType: viewModel.cardType,
                                onViewReflection: { viewModel.shouldShowReflection = true }
                            )
                            .id("cora-card")
                            ChatOnboardingSpacerAdapter()
                        }
                        .padding(.top, 85)
                        .padding(.bottom, 120)
                    }
                    .background(ChatOnboardingScrollAdapter(proxy: proxy))
                    .onAppear {
                        viewModel.setContext(modelContext)
                        viewModel.loadCards(checkIns: checkIns)
                    }
                    .onChange(of: checkIns.count) {
                        viewModel.loadData()
                        viewModel.loadCards(checkIns: checkIns)
                    }
                    .onReceive(navManager.$pendingWeeklyReflection) { pending in
                        if pending {
                            viewModel.handlePendingWeeklyReflection(checkIns: checkIns)
                        }
                    }
                }

                if let currentUser = users.first {
                    ProfileButton(user: currentUser)
                        .padding(.trailing, 16)
                        .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $viewModel.shouldShowReflection) {
                WeeklyReflectionView(userStreak: viewModel.currentStreak)
            }
        }
    }
}

private struct ChatOnboardingSpacerAdapter: View {
    @ObservedObject private var onboarding = OnboardingViewModel.shared

    var body: some View {
        if onboarding.isActive {
            Color.clear.frame(height: 300)
        } else {
            EmptyView()
        }
    }
}

private struct ChatOnboardingScrollAdapter: View {
    @ObservedObject private var onboarding = OnboardingViewModel.shared
    let proxy: ScrollViewProxy

    var body: some View {
        Color.clear
            .onChange(of: onboarding.currentStep) { _, step in
                if step == .coraCard {
                    withAnimation { proxy.scrollTo("cora-card", anchor: .top) }
                }
            }
    }
}

