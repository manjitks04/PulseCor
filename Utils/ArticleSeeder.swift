//
//  ArticleSeeder.swift
//  PulseCor

import Foundation
import SwiftData

struct ArticleSeeder {

    static func seedIfNeeded(in modelContext: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: "hasSeededArticles") else { return }

        let articles = buildArticles()
        for article in articles {
            modelContext.insert(article)
        }

        do {
            try modelContext.save()
            UserDefaults.standard.set(true, forKey: "hasSeededArticles")
        } catch {
            print("ArticleSeeder: failed to save articles — \(error)")
        }
    }

    private static func buildArticles() -> [Article] {
        [
            Article(
                title: "Improve your sleep",
                summary: "Better sleep changes everything",
                content: loadContent("improve_sleep"),
                category: .sleep,
                articleType: .helpfulArticle,
                imageName: "improve_sleep"
            ),
            Article(
                title: "Move more, sit less",
                summary: "Simple ways to stay active",
                content: loadContent("move_more"),
                category: .generalWellness,
                articleType: .helpfulArticle,
                imageName: "move_more"
            ),
            Article(
                title: "Practice mindfulness",
                summary: "Find calm in your day",
                content: loadContent("mindfulness"),
                category: .generalWellness,
                articleType: .helpfulArticle,
                imageName: "mindfulness"
            ),
            Article(
                title: "Holistic heart care",
                summary: "Taking care of your heart naturally",
                content: loadContent("heart_care"),
                category: .cardiovascular,
                articleType: .helpfulArticle,
                imageName: "heart_care"
            ),
            Article(
                title: "Prioritise your health",
                summary: "Make yourself a priority",
                content: loadContent("prioritise_health"),
                category: .generalWellness,
                articleType: .helpfulArticle,
                imageName: "prioritise_health"
            ),
            Article(
                title: "Fuel your body",
                summary: "Nutrition for better energy",
                content: loadContent("fuel_body"),
                category: .generalWellness,
                articleType: .helpfulArticle,
                imageName: "fuel_body"
            ),
            Article(
                title: "What are heart disease risk factors?",
                summary: "Understanding and reducing your risk",
                content: loadContent("heart_disease_risk"),
                category: .cardiovascular,
                articleType: .helpfulArticle,
                imageName: "heart_disease_risk"
            ),
            Article(
                title: "Can stress affect my body?",
                summary: "Understanding the stress-body connection",
                content: loadContent("stress_body"),
                category: .generalWellness,
                articleType: .helpfulArticle,
                imageName: "stress_body"
            ),
            Article(
                title: "How much water should I have?",
                summary: "Staying properly hydrated",
                content: loadContent("water_should"),
                category: .generalWellness,
                articleType: .helpfulArticle,
                imageName: "water_should"
            )
        ]
    }
    
    private static func loadContent(_ filename: String) -> String {
        guard let path = Bundle.main.path(forResource: filename, ofType: "txt", inDirectory: "Articles"),
              let content = try? String(contentsOfFile: path, encoding: .utf8)
        else {
            print("ArticleSeeder: could not find \(filename).txt in articles folder")
            return "Content not available."
        }
        return content
    }
}
