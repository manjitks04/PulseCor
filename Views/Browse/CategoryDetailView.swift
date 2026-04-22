//
//  CategoryDetailView.swift
//  PulseCor
//
//  Detail view for a specific health category (Cardiovascular, Sleep, or General Wellness).
//  Shows gradient header, quick stats, "Did you know" fact, and 3 random articles from category.
//

import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    let category: ArticleCategory
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BrowseViewModel()
    @State private var randomFact: String = ""

    var body: some View {
        ZStack(alignment: .top) {
            Color("MainBG").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Gradient header with back button, category name, and tagline
                    CategoryHeaderView(category: category, onBack: { dismiss() })

                    VStack(spacing: 24) {

                        // Quick stats cards
                        QuickStatsView(stats: category.stats, gradientColors: category.gradientColors)

                        // Random "Did you know" fact from category's fact pool
                        if !randomFact.isEmpty {
                            DidYouKnowCard(fact: randomFact, gradientColors: category.gradientColors)
                        }

                        // 3 random articles from this category (cached after first load)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Helpful Articles")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color("MainText"))

                            let columns = [
                                GridItem(.flexible(), spacing: 10),
                                GridItem(.flexible(), spacing: 10),
                                GridItem(.flexible(), spacing: 10)
                            ]

                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(viewModel.selectedCategoryArticles) { article in
                                    ArticleCard(article: article)
                                }
                            }
                        }

                        Spacer().frame(height: 60)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .task {
            viewModel.setContext(modelContext)
            viewModel.loadCategoryArticles(category: category)
            randomFact = category.didYouKnowFacts.randomElement() ?? ""
        }
    }
}

// Gradient header section with decorative blobs, back button, and category info
private struct CategoryHeaderView: View {
    let category: ArticleCategory
    let onBack: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Gradient background matching category theme
            LinearGradient(
                colors: category.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            // Decorative circular blobs
            BlobsView()

            VStack(alignment: .leading, spacing: 12) {
                // Back button positioned below status bar
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Browse")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 60)

                Spacer().frame(height: 8)

                // Category title
                HStack(alignment: .top, spacing: 10) {
                    Text(category.displayName)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .lineSpacing(2)

                }

                // Category tagline)
                Text(category.tagline)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.88))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 28)
            }
            .padding(.horizontal, 22)
        }
        .frame(maxWidth: .infinity)
    }
}

// Decorative circular blobs overlaid on gradient header
private struct BlobsView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 180, height: 180)
                .offset(x: 140, y: -40)

            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 130, height: 130)
                .offset(x: 100, y: 60)

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 90, height: 90)
                .offset(x: -30, y: -20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .clipped()
    }
}

// Row of stat cards showing category-specific metrics
private struct QuickStatsView: View {
    let stats: [CategoryStat]
    let gradientColors: [Color]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(stats.indices, id: \.self) { i in
                StatCard(stat: stats[i], gradientColors: gradientColors)
            }
        }
        .frame(height: 95)
    }
}

// Individual stat card with gradient-colored value and label
private struct StatCard: View {
    let stat: CategoryStat
    let gradientColors: [Color]

    var body: some View {
        VStack(spacing: 6) {
            Text(stat.value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            // Label explaining the stat
            Text(stat.label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("CardBG"))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
}

//"Did you know" fact card with lightbulb icon and gradient title
private struct DidYouKnowCard: View {
    let fact: String
    let gradientColors: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("💡")
                    .font(.system(size: 16))
                Text("Did you know?")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            // Random fact text from category's fact pool
            Text(fact)
                .font(.system(size: 14))
                .foregroundColor(Color("MainText").opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("CardBG"))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
}
