//
//  WeightEntry.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import Foundation
import SwiftData

/// Model for tracking body weight over time
@Model
final class WeightEntry {
    var id: UUID
    var date: Date
    var weight: Double  // in lbs or kg based on user preference
    var bodyFatPercentage: Double?
    var muscleMass: Double?  // optional, from smart scales
    var notes: String?
    var source: WeightSource
    
    @Relationship(deleteRule: .nullify, inverse: \UserProfile.weightEntries)
    var userProfile: UserProfile?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        weight: Double,
        bodyFatPercentage: Double? = nil,
        muscleMass: Double? = nil,
        notes: String? = nil,
        source: WeightSource = .manual
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.muscleMass = muscleMass
        self.notes = notes
        self.source = source
    }
    
    /// Calculate lean body mass if body fat is available
    var leanBodyMass: Double? {
        guard let bf = bodyFatPercentage else { return nil }
        return weight * (1 - bf / 100)
    }
    
    /// Calculate fat mass if body fat is available
    var fatMass: Double? {
        guard let bf = bodyFatPercentage else { return nil }
        return weight * (bf / 100)
    }
}

// MARK: - Weight Source

enum WeightSource: String, Codable {
    case manual = "manual"
    case healthKit = "health_kit"
    case smartScale = "smart_scale"
}

// MARK: - Weight Trend Calculator

struct WeightTrend {
    let entries: [WeightEntry]
    
    /// Calculate 7-day moving average
    var sevenDayAverage: Double? {
        let recentEntries = entries.suffix(7)
        guard !recentEntries.isEmpty else { return nil }
        return recentEntries.reduce(0) { $0 + $1.weight } / Double(recentEntries.count)
    }
    
    /// Calculate weekly change (comparing 7-day averages)
    var weeklyChange: Double? {
        guard entries.count >= 14 else { return nil }
        
        let recent7 = Array(entries.suffix(7))
        let previous7 = Array(entries.dropLast(7).suffix(7))
        
        let recentAvg = recent7.reduce(0) { $0 + $1.weight } / Double(recent7.count)
        let previousAvg = previous7.reduce(0) { $0 + $1.weight } / Double(previous7.count)
        
        return recentAvg - previousAvg
    }
    
    /// Calculate trend direction
    var trendDirection: TrendDirection {
        guard let change = weeklyChange else { return .stable }
        
        if change > 0.5 {
            return .increasing
        } else if change < -0.5 {
            return .decreasing
        } else {
            return .stable
        }
    }
    
    /// Calculate rate of change per week
    var weeklyRate: Double? {
        weeklyChange
    }
    
    /// Estimate time to reach goal
    func estimatedWeeksToGoal(_ goalWeight: Double) -> Int? {
        guard let rate = weeklyRate, abs(rate) > 0.1 else { return nil }
        guard let currentWeight = entries.last?.weight else { return nil }
        
        let difference = goalWeight - currentWeight
        
        // Check if we're moving in the right direction
        if (difference > 0 && rate < 0) || (difference < 0 && rate > 0) {
            return nil // Moving away from goal
        }
        
        return Int(ceil(abs(difference / rate)))
    }
}

enum TrendDirection {
    case increasing
    case decreasing
    case stable
    
    var icon: String {
        switch self {
        case .increasing: return "arrow.up.right"
        case .decreasing: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    var description: String {
        switch self {
        case .increasing: return "Gaining"
        case .decreasing: return "Losing"
        case .stable: return "Maintaining"
        }
    }
}
