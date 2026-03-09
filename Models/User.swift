//
//  User.swift
//  PulseCor
//

import Foundation
import SwiftData

@Model
class User{
    @Attribute(.unique) var id: Int
    var name: String
    var profilePic: String
    var createdAt: Date
    var lastCheckInDate: Date?
    var currentStreak: Int
    var longestStreak: Int
    
    // intialiser for creating new users
    init(id: Int = 1, name: String, profilePic: String = "PFP_1", createdAt: Date = Date(), lastCheckInDate: Date? = nil, currentStreak: Int = 0, longestStreak: Int = 0) {
        self.id = id
        self.name = name
        self.profilePic = profilePic
        self.createdAt = createdAt
        self.lastCheckInDate = lastCheckInDate
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
    }
}

