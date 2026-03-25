//
//  CategoryDetailView.swift
//  PulseCor
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

                    CategoryHeaderView(category: category, onBack: { dismiss() })

                    VStack(spacing: 24) {

                        QuickStatsView(stats: category.stats, gradientColors: category.gradientColors)

                        if !randomFact.isEmpty {
                            DidYouKnowCard(fact: randomFact, gradientColors: category.gradientColors)
                        }

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

                        if !viewModel.selectedCategoryFAQs.isEmpty {
                            FAQSection(
                                faqs: viewModel.selectedCategoryFAQs,
                                gradientColors: category.gradientColors
                            )
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

private struct CategoryHeaderView: View {
    let category: ArticleCategory
    let onBack: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: category.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            BlobsView()

            VStack(alignment: .leading, spacing: 12) {
                // Back button — sits below status bar
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

                HStack(alignment: .top, spacing: 10) {
                    Text(category.displayName)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .lineSpacing(2)

                }

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

private struct FAQSection: View {
    let faqs: [Article]
    let gradientColors: [Color]
    @State private var expandedID: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("FAQ's answered")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color("MainText"))

            VStack(spacing: 0) {
                ForEach(faqs) { faq in
                    FAQRow(
                        faq: faq,
                        isExpanded: expandedID == faq.id.uuidString,
                        accentColor: gradientColors.first ?? .pink
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            expandedID = expandedID == faq.id.uuidString ? nil : faq.id.uuidString
                        }
                    }

                    if faq.id != faqs.last?.id {
                        Divider().padding(.horizontal, 4)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("CardBG"))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
    }
}

private struct FAQRow: View {
    let faq: Article
    let isExpanded: Bool
    let accentColor: Color
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(alignment: .top, spacing: 12) {
                    Text(faq.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("MainText"))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                Text(faq.content)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
