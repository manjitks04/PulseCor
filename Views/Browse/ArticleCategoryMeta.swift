//
//  ArticleCategoryMeta.swift
//  PulseCor
//

import SwiftUI

struct CategoryStat {
    let value: String
    let label: String
}

extension ArticleCategory {

    var displayName: String {
        switch self {
        case .cardiovascular:  return "Cardiovascular\nWellness"
        case .sleep:           return "Sleep\nWellness"
        case .generalWellness: return "General\nWellness"
        }
    }

    var sfSymbol: String {
        switch self {
        case .cardiovascular:  return "heart.text.square"
        case .sleep:           return "bed.double.fill"
        case .generalWellness: return "figure.mind.and.body"
        }
    }

    var tagline: String {
        switch self {
        case .cardiovascular:
            return "Ready to give your heart some love? Dive into our articles covering a broad range of topics & find clarity with common questions answered regarding cardiovascular health!"
        case .sleep:
            return "Great sleep changes everything. Explore our articles to understand your sleep cycles, build better habits, and wake up feeling genuinely restored."
        case .generalWellness:
            return "Small daily choices add up to big change. Browse our articles on nutrition, movement, mental health, and everything in between."
        }
    }

    var stats: [CategoryStat] {
        switch self {
        case .cardiovascular:
            return [
                CategoryStat(value: "#1", label: "cause of death globally"),
                CategoryStat(value: "80%", label: "of cases are preventable"),
                CategoryStat(value: "30min", label: "daily exercise recommended")
            ]
        case .sleep:
            return [
                CategoryStat(value: "7–9hrs", label: "recommended for adults"),
                CategoryStat(value: "1 in 3", label: "adults sleep poorly"),
                CategoryStat(value: "90min", label: "per sleep cycle")
            ]
        case .generalWellness:
            return [
                CategoryStat(value: "150min", label: "weekly activity goal"),
                CategoryStat(value: "2L", label: "daily water intake"),
                CategoryStat(value: "5x", label: "fruit & veg per day")
            ]
        }
    }

    var didYouKnowFacts: [String] {
        switch self {
        case .cardiovascular:
            return [
                "Your heart beats around 100,000 times every single day, that's over 2.5 billion beats in an average lifetime.",
                "Laughing is genuinely good for your heart, it relaxes blood vessels and increases blood flow.",
                "The risk of heart disease is significantly higher for people who regularly sleep less than 6 hours per night.",
                "Regular moderate exercise can reduce your risk of heart disease by up to 35%.",
                "Dark chocolate (70%+ cocoa) contains flavonoids that can help lower blood pressure.",
                "People with strong social connections have a 29% lower risk of heart disease."
            ]
        case .sleep:
            return [
                "Your brain clears out toxic waste products during sleep, a process that barely happens when you're awake.",
                "After 17 hours without sleep, your performance is equivalent to a blood alcohol level of 0.05%.",
                "Humans are the only mammals that deliberately delay sleep.",
                "A consistent wake time is more important than a consistent bedtime for regulating your body clock.",
                "Your body temperature drops by about 1°C as you fall asleep — a cool bedroom speeds this up.",
                "The blue light from screens delays melatonin production by up to 3 hours."
            ]
        case .generalWellness:
            return [
                "It takes an average of 66 days to form a new habit — not 21 as the popular myth suggests.",
                "Just 20 minutes in a natural environment is enough to measurably lower cortisol levels.",
                "People who eat 30+ different plant foods per week have significantly more diverse gut microbiomes.",
                "Walking briskly for 30 minutes a day reduces the risk of depression by up to 36%.",
                "Chronic loneliness has the same health impact as smoking 15 cigarettes a day.",
                "Drinking water first thing in the morning reduces mild fatigue, most people wake up mildly dehydrated."
            ]
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .cardiovascular:
            return [Color("AccentCoral"), Color("AccentPink")]
        case .sleep:
            return [Color(red: 0.35, green: 0.30, blue: 0.70), Color(red: 0.55, green: 0.40, blue: 0.80)]
        case .generalWellness:
            return [Color(red: 0.20, green: 0.60, blue: 0.45), Color(red: 0.35, green: 0.75, blue: 0.55)]
        }
    }
}
