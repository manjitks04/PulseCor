//
//  HealthModels.swift
//  PulseCor
//
//
import Foundation
import SwiftData

@Model
class StepEntry {
    var id: UUID
    var count: Double
    var date: Date
    
    init(count: Double, date: Date) {
        self.id = UUID()
        self.count = count
        self.date = date
    }
}

@Model
class HeartRateEntry {
    var id: UUID
    var bpm: Double
    var date: Date
    
    init(bpm: Double, date: Date) {
        self.id = UUID()
        self.bpm = bpm
        self.date = date
    }
}

@Model
class RestingHeartRateEntry {
    var id: UUID
    var bpm: Double
    var date: Date
    
    init(bpm: Double, date: Date) {
        self.id = UUID()
        self.bpm = bpm
        self.date = date
    }
}

@Model
class HRVEntry {
    var id: UUID
    var ms: Double 
    var date: Date
    
    init(ms: Double, date: Date) {
        self.id = UUID()
        self.ms = ms
        self.date = date
    }
}
