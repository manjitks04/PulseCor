//
//  ConversationView.swift
//  PulseCor
//
//

import SwiftUI

struct ConversationView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
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
                        
                        if viewModel.isTyping {
                            TypingIndicator()
                        }
                    }
                    .id("bottomOfMessages")
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation {
                        proxy.scrollTo("bottomOfMessages", anchor: .bottom)
                    }
                }
                .onAppear {
                    withAnimation {
                        proxy.scrollTo("bottomOfMessages", anchor: .bottom)
                    }
                }
            }
            
            if !viewModel.currentQuickReplies.isEmpty {
                QuickReplyButtons(replies: viewModel.currentQuickReplies) { reply in
                    viewModel.handleUserResponse(reply)
                }
            }
        }
        .navigationTitle("Cora")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("MainBG"))
        .onAppear {
            if viewModel.messages.isEmpty {
                viewModel.startDailyCheckIn()
            }
        }
    }
}

struct CoraMessageBubble: View {
    let message: String
    
    var body: some View {
        HStack{
            Text(message)
                .padding(12)
                .background(Color("CardBG"))
                .cornerRadius(16)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

struct UserMessageBubble: View {
    let message: String
    
    var body: some View {
        HStack{
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
