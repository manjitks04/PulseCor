//
//  BrowseViewModel.swift
//  PulseCor
//
import Foundation
import SwiftData
import Combine
@MainActor
class BrowseViewModel: ObservableObject {

    @Published var browseSection1: [Article] = []
    @Published var browseSection2: [Article] = []
    @Published var browseSection3: [Article] = []

    @Published var selectedCategoryArticles: [Article] = []
    @Published var selectedCategoryFAQs: [Article] = []

    @Published var errorMessage: String?

    private var modelContext: ModelContext?
    private static var hasLoadedThisSession = false
    private static var categoryCache: [ArticleCategory: [Article]] = [:] 

    init() {}

    func setContext(_ context: ModelContext) {
        self.modelContext = context
        if !BrowseViewModel.hasLoadedThisSession {
            loadRandomArticles()
            BrowseViewModel.hasLoadedThisSession = true
        }
    }

    func loadRandomArticles() {
        let pool = fetchAllArticles()
            .filter { $0.articleType == .helpfulArticle && $0.showOnBrowse }
            .shuffled()
        browseSection1 = Array(pool.prefix(3))
        browseSection2 = Array(pool.dropFirst(3).prefix(3))
        browseSection3 = Array(pool.dropFirst(6).prefix(3))
    }

    func loadCategoryArticles(category: ArticleCategory) {
        if let cached = BrowseViewModel.categoryCache[category] {
            selectedCategoryArticles = cached
            return
        }

        let all = fetchAllArticles()
        let articles = Array(
            all.filter { $0.category == category && $0.articleType == .helpfulArticle }.shuffled().prefix(3)
        )
        BrowseViewModel.categoryCache[category] = articles
        selectedCategoryArticles = articles
        selectedCategoryFAQs = all.filter { $0.category == category && $0.articleType == .faq }
    }

    private func fetchAllArticles() -> [Article] {
        guard let modelContext else { return [] }
        return (try? modelContext.fetch(FetchDescriptor<Article>())) ?? []
    }
}
