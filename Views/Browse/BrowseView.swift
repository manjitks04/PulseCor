//
//  BrowseView.swift
//  PulseCor
//
import SwiftUI
import SwiftData

struct BrowseView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = BrowseViewModel()
    @Query private var users: [User]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Color("MainBG").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .topTrailing) {

                        VStack(spacing: 24) {

                            HStack(alignment: .top, spacing: 0) {
                                CategoryNavButton(category: .cardiovascular)
                                CategoryNavButton(category: .sleep)
                                CategoryNavButton(category: .generalWellness)
                            }
                            .padding(.top, 25)

                            Group {
                                ArticleSection(title: "General Tips", articles: viewModel.browseSection1)
                                ArticleSection(title: "Ideas to try", articles: viewModel.browseSection2)
                                ArticleSection(title: "Helpful Articles", articles: viewModel.browseSection3)
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
            .task { viewModel.setContext(modelContext) }
        }
    }
}


struct CategoryNavButton: View {
    let category: ArticleCategory

    var body: some View {
        NavigationLink(destination: CategoryDetailView(category: category)) {
            VStack(spacing: 8) {
                Image(systemName: category.sfSymbol)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(height: 52) 

                Text(category.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(CategoryNavButtonStyle())
    }
}
private struct CategoryNavButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}


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

            if articles.isEmpty {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.12))
                            .frame(height: 140)
                    }
                }
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(articles) { article in
                        ArticleCard(article: article)
                    }
                }
            }
        }
    }
}

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
            .frame(height: 150)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

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
