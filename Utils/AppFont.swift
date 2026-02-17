//
//  AppFont.swift
//  PulseCor
//
//  Created by Manjit Somal on 17/02/2026.
//
//helps accessibility needs by keeping fonts relative to users iOS settings

import SwiftUI

extension Font {
    // Hero / Large Titles
    static let appHero = Font.system(size: 42, relativeTo: .largeTitle)
    static let appHeroBold = Font.system(size: 42, weight: .bold,    relativeTo: .largeTitle)
    static let appHeroTitle = Font.system(size: 32, weight: .bold,    relativeTo: .largeTitle)
    static let appHeroCardTitle  = Font.system(size: 36, weight: .bold,    relativeTo: .largeTitle)

    // Titles
    static let appTitle = Font.system(size: 28, weight: .bold,    relativeTo: .title)
    static let appTitle2Semibold = Font.system(size: 24, weight: .semibold, relativeTo: .title2)
    static let appTitle2Bold = Font.system(size: 24, weight: .bold,    relativeTo: .title2)
    static let appTitle2 = Font.system(size: 24, relativeTo: .title2)

    // Section / Subtitles
    static let appSectionTitle = Font.system(size: 16, relativeTo: .title3)
    static let appSectionTitleBold = Font.system(size: 16, weight: .bold,    relativeTo: .title3)
    static let appSectionTitleMedium = Font.system(size: 16, weight: .medium,  relativeTo: .title3)
    static let appSectionHeaderSemibold = Font.system(size: 22, weight: .semibold, relativeTo: .title2)
    static let appSubtitleSemibold = Font.system(size: 20, weight: .semibold, relativeTo: .headline)
    static let appSubtitle  = Font.system(size: 20, relativeTo: .headline)

    // Body
    static let appBodyLargeSemibold = Font.system(size: 18, weight: .semibold, relativeTo: .body)
    static let appBodyLarge = Font.system(size: 18, relativeTo: .body)
    static let appBody = Font.system(size: 12, relativeTo: .body)
    static let appBodySemibold = Font.system(size: 12, weight: .semibold, relativeTo: .body)

    // Card Titles
    static let appCardTitle = Font.system(size: 14, relativeTo: .headline)
    static let appCardTitleBold = Font.system(size: 14, weight: .bold,    relativeTo: .headline)
    static let appCardTitleSemibold = Font.system(size: 14, weight: .semibold, relativeTo: .headline)

    // Small / Caption
    static let appSmallBody = Font.system(size: 11, relativeTo: .callout)
    static let appSmallBodyMedium = Font.system(size: 11, weight: .medium, relativeTo: .callout)
    static let appSmallBodyBold = Font.system(size: 11, weight: .bold,   relativeTo: .callout)
    static let appCaption = Font.system(size: 10, weight: .medium, relativeTo: .caption)

    // Calendar
    static let appDayNumber = Font.system(size: 15, relativeTo: .body)
    static let appDayNumberBold = Font.system(size: 15, weight: .bold, relativeTo: .body)

    // Streak
    static let appStreakNumber = Font.system(size: 34, weight: .bold, relativeTo: .largeTitle)

    // Links
    static let appLink = Font.system(size: 16, relativeTo: .body)

    // Icons
    static let appIcon = Font.system(size: 40, relativeTo: .largeTitle)
    static let appLargeIcon = Font.system(size: 48, relativeTo: .largeTitle)
    static let appMediumIcon = Font.system(size: 28, relativeTo: .title)
}

extension Font {
    static func system(size: CGFloat, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle) -> Font {
        .custom("", size: size, relativeTo: style).weight(weight)
    }
}
