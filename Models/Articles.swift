//
//  Articles.swift
//  PulseCor
//
//
import Foundation

struct Article: Codable, Identifiable {
    let id: Int?
    let title: String
    let summary: String
    let content: String
    let category: ArticleCategory
    let articleType: ArticleType
    let imageName: String?
    
    init(id: Int? = nil, title: String, summary: String, content: String, category: ArticleCategory, articleType: ArticleType, imageName: String? = nil) {
        self.id = id
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
