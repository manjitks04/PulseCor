//
//  Article.swift
//  PulseCor
//
import Foundation
import SwiftData

// Articles are seeded from text files on app launch and categorised by health topic.
@Model
class Article {
    var id: UUID = UUID()
    var title: String
    var summary: String
    var content: String
    var category: ArticleCategory
    var articleType: ArticleType
    var imageName: String?
    var showOnBrowse: Bool = true

    init(
        title: String,
        summary: String,
        content: String,
        category: ArticleCategory,
        articleType: ArticleType,
        imageName: String? = nil,
        showOnBrowse: Bool = true
    ) {
        self.title = title
        self.summary = summary
        self.content = content
        self.category = category
        self.articleType = articleType
        self.imageName = imageName
        self.showOnBrowse = showOnBrowse
    }
}

enum ArticleCategory: String, Codable, CaseIterable {
    case cardiovascular = "Cardiovascular Health"
    case sleep = "Sleep"
    case generalWellness = "General Wellness"
}

enum ArticleType: String, Codable {
    case helpfulArticle = "helpful_article"
    case faq = "faq"
}
