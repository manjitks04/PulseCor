//
//  ArticleSeeder.swift
//  PulseCor
//
//  Populates SwiftData with educational articles on first app launch.
//

import Foundation
import SwiftData

struct ArticleSeeder {

    // Uses UserDefaults flag to prevent duplicate seeding across app launches.
    static func seedIfNeeded(in modelContext: ModelContext) {
        let existing = (try? modelContext.fetch(FetchDescriptor<Article>())) ?? []
        if existing.contains(where: { $0.content == "Content not available." }) {
            UserDefaults.standard.removeObject(forKey: "hasSeededArticles")
            try? modelContext.delete(model: Article.self)
        }

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

    // Combines total 27 articles across 3 categories
    private static func buildArticles() -> [Article] {
        browseArticles() + categoryOnlyArticles()
    }

    // Articles features on main browse tab
    private static func browseArticles() -> [Article] {
        [
            Article(title: "Improve your sleep", summary: "Better sleep changes everything", content: loadContent("improve_sleep"), category: .sleep, articleType: .helpfulArticle, imageName: "improve_sleep", showOnBrowse: true),
            Article(title: "Holistic heart care", summary: "Taking care of your heart naturally", content: loadContent("heart_care"), category: .cardiovascular, articleType: .helpfulArticle, imageName: "heart_care", showOnBrowse: true),
            Article(title: "What are heart disease risk factors?", summary: "Understanding and reducing your risk", content: loadContent("heart_disease_risk"), category: .cardiovascular, articleType: .helpfulArticle, imageName: "heart_disease_risk", showOnBrowse: true),
            Article(title: "Move more, sit less", summary: "Simple ways to stay active", content: loadContent("move_more"), category: .generalWellness, articleType: .helpfulArticle, imageName: "move_more", showOnBrowse: true),
            Article(title: "Practice mindfulness", summary: "Find calm in your day", content: loadContent("mindfulness"), category: .generalWellness, articleType: .helpfulArticle, imageName: "mindfulness", showOnBrowse: true),
            Article(title: "Prioritise your health", summary: "Make yourself a priority", content: loadContent("prioritise_health"), category: .generalWellness, articleType: .helpfulArticle, imageName: "prioritise_health", showOnBrowse: true),
            Article(title: "Fuel your body", summary: "Nutrition for better energy", content: loadContent("fuel_body"), category: .generalWellness, articleType: .helpfulArticle, imageName: "fuel_body", showOnBrowse: true),
            Article(title: "Can stress affect my body?", summary: "Understanding the stress-body connection", content: loadContent("stress_body"), category: .generalWellness, articleType: .helpfulArticle, imageName: "stress_body", showOnBrowse: true),
            Article(title: "How much water should I have?", summary: "Staying properly hydrated", content: loadContent("water_should"), category: .generalWellness, articleType: .helpfulArticle, imageName: "water_should", showOnBrowse: true)
        ]
    }

    private static func categoryOnlyArticles() -> [Article] {
        [
            // Sleep
            Article(title: "Understanding sleep cycles", summary: "What really happens while you rest", content: loadContent("sleep_cycles"), category: .sleep, articleType: .helpfulArticle, imageName: "sleep_cycles", showOnBrowse: false),
            Article(title: "Build a bedtime routine", summary: "Signal your brain it's time to sleep", content: loadContent("bedtime_routine"), category: .sleep, articleType: .helpfulArticle, imageName: "bedtime_routine", showOnBrowse: false),
            Article(title: "Foods that help you sleep", summary: "What to eat (and avoid) before bed", content: loadContent("sleep_foods"), category: .sleep, articleType: .helpfulArticle, imageName: "sleep_foods", showOnBrowse: false),
            Article(title: "Sleep and your heart", summary: "The cardiovascular link to rest", content: loadContent("sleep_heart"), category: .sleep, articleType: .helpfulArticle, imageName: "sleep_heart", showOnBrowse: false),
            Article(title: "Managing sleep anxiety", summary: "Break the cycle of sleepless nights", content: loadContent("sleep_anxiety"), category: .sleep, articleType: .helpfulArticle, imageName: "sleep_anxiety", showOnBrowse: false),
            Article(title: "The power of napping", summary: "Nap smarter, not longer", content: loadContent("power_napping"), category: .sleep, articleType: .helpfulArticle, imageName: "power_napping", showOnBrowse: false),
            Article(title: "Blue light and sleep", summary: "Why screens affect your rest", content: loadContent("blue_light_sleep"), category: .sleep, articleType: .helpfulArticle, imageName: "blue_light_sleep", showOnBrowse: false),
            Article(title: "Sleep temperature", summary: "How to create the ideal sleep environment", content: loadContent("sleep_temperature"), category: .sleep, articleType: .helpfulArticle, imageName: "sleep_temperature", showOnBrowse: false),
            // Cardiovascular
            Article(title: "Understanding your heart rate", summary: "What your numbers really mean", content: loadContent("understanding_heart_rate"), category: .cardiovascular, articleType: .helpfulArticle, imageName: "understanding_heart_r", showOnBrowse: false),
            Article(title: "Exercise for heart health", summary: "Move your way to a stronger heart", content: loadContent("exercise_heart"), category: .cardiovascular, articleType: .helpfulArticle, imageName: "exercise_heart", showOnBrowse: false),
            Article(title: "Heart-healthy foods", summary: "Eat your way to better heart health", content: loadContent("heart_healthy_foods"), category: .cardiovascular, articleType: .helpfulArticle, imageName: "heart_healthy_foods", showOnBrowse: false),
            Article(title: "Managing blood pressure naturally", summary: "Lifestyle changes that make a difference", content: loadContent("blood_pressure"), category: .cardiovascular, articleType: .helpfulArticle, imageName: "blood_pressure", showOnBrowse: false),
            Article(title: "Stress and your heart", summary: "How to protect your heart from chronic stress", content: loadContent("stress_heart"), category: .cardiovascular, articleType: .helpfulArticle, imageName: "stress_heart", showOnBrowse: false),
            Article(title: "Heart warning signs", summary: "When to act and when to seek help", content: loadContent("heart_warning_signs"), category: .cardiovascular, articleType: .helpfulArticle, imageName: "heart_warning_signs", showOnBrowse: false),
            Article(title: "Heart health at every age", summary: "It's never too early or too late", content: loadContent("heart_health_age"), category: .cardiovascular, articleType: .helpfulArticle, imageName: "heart_health_age", showOnBrowse: false),
            // General Wellness
            Article(title: "Building healthy habits", summary: "Small changes, lasting results", content: loadContent("healthy_habits"), category: .generalWellness, articleType: .helpfulArticle, imageName: "healthy_habits", showOnBrowse: false),
            Article(title: "The importance of rest", summary: "Why recovery is not laziness", content: loadContent("importance_of_rest"), category: .generalWellness, articleType: .helpfulArticle, imageName: "importance_of_rest", showOnBrowse: false),
            Article(title: "Social connections and health", summary: "Why relationships are medicine", content: loadContent("social_connections"), category: .generalWellness, articleType: .helpfulArticle, imageName: "social_connections", showOnBrowse: false)
        ]
    }

    // Loads article content from .txt file
    private static func loadContent(_ filename: String) -> String {
        guard let path = Bundle.main.path(forResource: filename, ofType: "txt"),
              let content = try? String(contentsOfFile: path, encoding: .utf8)
        else {
            print("ArticleSeeder: could not find \(filename).txt")
            return "Content not available."
        }
        return content
    }
}
