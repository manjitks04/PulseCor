//
//  BrowseViewModel.swift
//  PulseCor
//
import Foundation
import SwiftData
import Combine

@MainActor
class BrowseViewModel: ObservableObject {

    @Published var sleepArticles: [Article] = []
    @Published var cardiovascularArticles: [Article] = []
    @Published var generalArticles: [Article] = []

    @Published var selectedCategoryArticles: [Article] = []
    @Published var selectedCategoryFAQs: [Article] = []

    @Published var errorMessage: String?

    private var modelContext: ModelContext?
    private static var hasLoadedThisSession = false

    init() {}

    func setContext(_ context: ModelContext) {
        self.modelContext = context
        if !BrowseViewModel.hasLoadedThisSession {
            loadRandomArticles()
            BrowseViewModel.hasLoadedThisSession = true
        }
    }

    func loadRandomArticles() {
        let all = fetchAllArticles().filter { $0.articleType == .helpfulArticle }
        sleepArticles         = Array(all.filter { $0.category == .sleep }.shuffled().prefix(3))
        cardiovascularArticles = Array(all.filter { $0.category == .cardiovascular }.shuffled().prefix(3))
        generalArticles       = Array(all.filter { $0.category == .generalWellness }.shuffled().prefix(3))
    }

    func loadCategoryArticles(category: ArticleCategory) {
        let all = fetchAllArticles()
        selectedCategoryArticles = Array(
            all.filter { $0.category == category && $0.articleType == .helpfulArticle }.shuffled().prefix(3)
        )
        selectedCategoryFAQs = all.filter { $0.category == category && $0.articleType == .faq }
    }

    private func fetchAllArticles() -> [Article] {
        guard let modelContext else { return [] }
        return (try? modelContext.fetch(FetchDescriptor<Article>())) ?? []
    }
}
