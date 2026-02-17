//
//  BrowseView.swift
//  PulseCor
//
//used for articles / educational content

import SwiftUI
import SwiftData

struct BrowseView: View {
    @StateObject private var viewModel = BrowseViewModel()
    @Query private var users: [User]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Color("MainBG")
                    .ignoresSafeArea()
                
                ScrollView {
                    ZStack(alignment: .topTrailing) {
                        
                        VStack(spacing: 24) {
                            // Category Icons
                            HStack(alignment: .top, spacing: 0) {
                                VStack(spacing: 8) {
                                    Image(systemName: "heart.text.square")
                                        .font(.system(size: 48, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Text("Cardiovascular Health")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity)
                                
                                // Sleep
                                VStack(spacing: 8) {
                                    Image(systemName: "bed.double.fill")
                                        .font(.system(size: 48, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Text("Sleep")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity)
                                
                                // General Wellness
                                VStack(spacing: 8) {
                                    Image(systemName: "figure.mind.and.body")
                                        .font(.system(size: 48, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Text("General Wellness")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.top, 25)
                            
                            // Sections
                            Group {
                                ArticleSection(
                                    title: "General Tips",
                                    articles: Array(viewModel.generalArticles.prefix(3))
                                )
                                
                                ArticleSection(
                                    title: "Ideas to try",
                                    articles: Array(viewModel.generalArticles.dropFirst(3).prefix(3))
                                )
                                
                                ArticleSection(
                                    title: "Helpful Articles",
                                    articles: Array(viewModel.generalArticles.dropFirst(6).prefix(3))
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 75)
                        .padding(.bottom, 100)
                        
                        if let currentUser = users.first {
                            ProfileButton(user: currentUser)
                                .padding(.trailing, 16)
                                .padding(.top, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

//Category Button Component
struct CategoryButton: View {
    let icon: String
    let label: String
    let category: ArticleCategory
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.secondary)
                .frame(height: 30)
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}

//Article Section Component
struct ArticleSection: View {
    let title: String
    let articles: [Article]
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("MainText"))
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(articles) { article in
                    ArticleCard(article: article)
                }
            }
        }
    }
}

//Article Card Component
struct ArticleCard: View {
    let article: Article
    
    var body: some View {
        NavigationLink(destination: ArticleDetailView(article: article)) {
            GeometryReader { geo in
                ZStack(alignment: .bottomLeading) {
                    Group {
                        if let imageName = article.imageName {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    
                    Text(article.title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .padding(8)
                }
            }
            .frame(height: 140)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//strucs to be moved to correct files later
