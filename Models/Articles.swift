//
//  Article.swift
//  PulseCor
//
import Foundation
import SwiftData

@Model
class Article {
    var title: String
    var summary: String
    var content: String
    var category: ArticleCategory
    var articleType: ArticleType
    var imageName: String?

    init(
        title: String,
        summary: String,
        content: String,
        category: ArticleCategory,
        articleType: ArticleType,
        imageName: String? = nil
    ) {
        self.title = title
        self.summary = summary
        self.content = content
        self.category = category
        self.articleType = articleType
        self.imageName = imageName
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
