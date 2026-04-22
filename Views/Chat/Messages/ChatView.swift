//
//  ChatView.swift
//  PulseCor
//
//  Main Cora tab view showing hero check-in card, streak tracker, and daily/weekly cards.
//  Handles weekly reflection trigger from notifications and onboarding coordination.
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
                        ZStack(alignment: .topTrailing) {

                            VStack(spacing: 16) {
                                // Hero card with check-in prompt or completion status
                                HeroCheckInCard(
                                    userName: users.first?.name ?? "there",
                                    hasCheckedInToday: viewModel.hasCheckedInToday
                                )
                                
                                // Weekly streak progress tracker (0-7 days)
                                DailyStreakTracker(currentDay: viewModel.currentStreak)
                                
                                // Daily tip or weekly reflection card (rotates by day of week)
                                CoraCardView(
                                    cardType: viewModel.cardType,
                                    onViewReflection: { viewModel.shouldShowReflection = true }
                                )
                                .id("cora-card")
                                
                                // Spacer expands during onboarding to prevent bottom sheet overlap
                                ChatOnboardingSpacerAdapter()
                            }
                            .padding(.top, 85)
                            .padding(.bottom, 120)

                            if let currentUser = users.first {
                                ProfileButton(user: currentUser)
                                    .padding(.trailing, 16)
                                    .padding(.top, 20)
                            }
                        }
                    }
                    // Invisible background view that handles auto-scroll during onboarding
                    .background(ChatOnboardingScrollAdapter(proxy: proxy))
                    .onAppear {
                        viewModel.setContext(modelContext)
                        viewModel.loadCards(checkIns: checkIns)
                    }
                    // Refreshes card type when check-ins count changes
                    .onChange(of: checkIns.count) {
                        viewModel.loadData()
                        viewModel.loadCards(checkIns: checkIns)
                    }
                    // Watches for pending weekly reflection from notification
                    .onReceive(navManager.$pendingWeeklyReflection) { pending in
                        if pending {
                            viewModel.handlePendingWeeklyReflection(checkIns: checkIns)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            // Weekly reflection presented as full-screen cover
            .fullScreenCover(isPresented: $viewModel.shouldShowReflection) {
                WeeklyReflectionView(userStreak: viewModel.currentStreak)
            }
        }
    }
}

// Adds bottom padding during onboarding to prevent content being hidden by overlay
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

// Invisible background view that auto-scrolls to Cora card during onboarding
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
