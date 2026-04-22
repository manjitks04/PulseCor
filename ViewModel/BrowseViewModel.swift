//
//  BrowseViewModel.swift
//  PulseCor
//
//  Manages article data for Browse tab and category detail views
//  Implements session-based caching to prevent re-shuffling on tab switches
//


import Foundation
import SwiftData
import Combine
@MainActor
class BrowseViewModel: ObservableObject {

    // Shuffles once per app session (reopeen)
    @Published var browseSection1: [Article] = []
    @Published var browseSection2: [Article] = []
    @Published var browseSection3: [Article] = []

    @Published var selectedCategoryArticles: [Article] = []

    @Published var errorMessage: String?

    private var modelContext: ModelContext?
    private static var hasLoadedThisSession = false //prevents reshuffling, resets when app relaunches
    private static var categoryCache: [ArticleCategory: [Article]] = [:] // caches category articles to avoid requerying

    init() {}
    
    // Sets ModelContext and triggers initial article load if first time this session, called from BrowseView.onAppear
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
    }

    private func fetchAllArticles() -> [Article] {
        guard let modelContext else { return [] }
        return (try? modelContext.fetch(FetchDescriptor<Article>())) ?? []
    }
}
