//
//  BrowseViewModel.swift
//  PulseCor
//
//
import Foundation
import Combine

class BrowseViewModel: ObservableObject {
    @Published var generalArticles: [Article] = []
    @Published var selectedCategoryArticles: [Article] = []
    @Published var selectedCategoryFAQs: [Article] = []
    @Published var errorMessage: String?
    
    private let databaseService: DatabaseService
    private static var hasLoadedThisSession = false
    
    init(databaseService: DatabaseService = .shared) {
        self.databaseService = databaseService
        
        if !BrowseViewModel.hasLoadedThisSession {
                    loadRandomArticles()
                    BrowseViewModel.hasLoadedThisSession = true
        }
    }
    
    //3 of 9 rotation
    func loadRandomArticles() {
        do {
            generalArticles = try databaseService.getRandomArticles(
                category: nil,
                type: .helpfulArticle,
                limit: 9
            )
        } catch {
            handleError(error)
        }
    }
    
    func loadCategoryArticles(category: ArticleCategory) {
        do {
            selectedCategoryArticles = try databaseService.getRandomArticles(
                category: category,
                type: .helpfulArticle,
                limit: 3
            )
            
            selectedCategoryFAQs = try databaseService.getArticlesByCategory(
                category: category,
                type: .faq
            )
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        print("BrowseViewModel Error: \(error)")
        errorMessage = "Failed to load articles. Please try again."
    }
}
