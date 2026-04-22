//
//  ConversationView.swift
//  PulseCor
//
//  Chat interface for daily check-in conversation with Cora.
//  Displays message bubbles, typing indicator, and quick reply buttons.
//

import SwiftUI
import SwiftData

struct ConversationView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        VStack(spacing: 0) {
            messageList
            quickReplies
        }
        .navigationTitle("Cora")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("MainBG"))
        .onAppear {
            viewModel.setContext(modelContext)
            // Starts check-in flow if no messages exist (first visit or new session)
            if viewModel.messages.isEmpty { viewModel.startDailyCheckIn() }
        }
        // Badge unlock sheet appears when user reaches new streak milestone
        .sheet(item: $viewModel.unlockedBadge) { badge in
            BadgeUnlockSheet(badge: badge) { viewModel.unlockedBadge = nil }
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
    }

    // Scrollable message list with auto-scroll to bottom
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        if message.sender == .cora {
                            CoraMessageBubble(message: message.content)
                        } else {
                            UserMessageBubble(message: message.content)
                        }
                    }
                    // Typing indicator shown while Cora is "thinking"
                    if viewModel.isTyping { TypingIndicator() }
                    Color.clear.frame(height: 1).id("bottomOfMessages")
                }
            }
            .onChange(of: viewModel.messages.count) {
                withAnimation { proxy.scrollTo("bottomOfMessages", anchor: .bottom) }
            }
            .onAppear {
                withAnimation { proxy.scrollTo("bottomOfMessages", anchor: .bottom) }
            }
        }
    }

    // Quick reply buttons shown when Cora offers multiple choice responses
    @ViewBuilder
    private var quickReplies: some View {
        if !viewModel.currentQuickReplies.isEmpty {
            QuickReplyButtons(replies: viewModel.currentQuickReplies) { reply in
                viewModel.handleUserResponse(reply)
            }
        }
    }
}

// Cora's message bubble (left-aligned, card background)
struct CoraMessageBubble: View {
    let message: String
    var body: some View {
        HStack {
            Text(message)
                .padding(12)
                .background(Color("CardBG"))
                .cornerRadius(16)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

// User's message bubble (right-aligned, coral gradient)
struct UserMessageBubble: View {
    let message: String
    var body: some View {
        HStack {
            Spacer()
            Text(message)
                .padding(12)
                .background(Color("AccentCoral"))
                .cornerRadius(16)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
    }
}

// Animated three-dot typing indicator shown while Cora is composing response
struct TypingIndicator: View {
    @State private var animating = false
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animating ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.28)
                                .repeatForever()
                                .delay(Double(index) * 0.3),
                            value: animating
                        )
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(16)
            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear { animating = true }
    }
}
