//
//  StreakData.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import Foundation
import SwiftData

/// Model for tracking user consistency streaks
@Model
final class StreakData {
    var id: UUID
    
    // MARK: - Current Streaks
    
    /// Current consecutive days with workout logged
    var currentWorkoutStreak: Int
    
    /// Current consecutive days with nutrition logged
    var currentNutritionStreak: Int
    
    /// Current consecutive days with both workout AND nutrition logged
    var currentCombinedStreak: Int
    
    // MARK: - Best Streaks (All-time records)
    
    var longestWorkoutStreak: Int
    var longestNutritionStreak: Int
    var longestCombinedStreak: Int
    
    // MARK: - Dates
    
    /// Last date a workout was logged
    var lastWorkoutDate: Date?
    
    /// Last date nutrition was logged
    var lastNutritionDate: Date?
    
    /// Date current workout streak started
    var workoutStreakStartDate: Date?
    
    /// Date current nutrition streak started
    var nutritionStreakStartDate: Date?
    
    // MARK: - Grace Period
    
    /// Number of grace days remaining (allows 1 miss without breaking streak)
    var graceDaysRemaining: Int
    
    /// Whether grace period is currently active
    var isGracePeriodActive: Bool
    
    // MARK: - Statistics
    
    /// Total workout days all time
    var totalWorkoutDays: Int
    
    /// Total nutrition logging days all time
    var totalNutritionDays: Int
    
    /// Days since account creation
    var daysSinceStart: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
    
    /// Workout consistency percentage (workout days / total days)
    var workoutConsistency: Double {
        guard daysSinceStart > 0 else { return 0 }
        return Double(totalWorkoutDays) / Double(daysSinceStart) * 100
    }
    
    /// Nutrition consistency percentage
    var nutritionConsistency: Double {
        guard daysSinceStart > 0 else { return 0 }
        return Double(totalNutritionDays) / Double(daysSinceStart) * 100
    }
    
    var createdAt: Date
    var lastUpdated: Date
    
    @Relationship(deleteRule: .nullify)
    var userProfile: UserProfile?
    
    init(
        id: UUID = UUID(),
        currentWorkoutStreak: Int = 0,
        currentNutritionStreak: Int = 0,
        currentCombinedStreak: Int = 0,
        longestWorkoutStreak: Int = 0,
        longestNutritionStreak: Int = 0,
        longestCombinedStreak: Int = 0,
        lastWorkoutDate: Date? = nil,
        lastNutritionDate: Date? = nil,
        workoutStreakStartDate: Date? = nil,
        nutritionStreakStartDate: Date? = nil,
        graceDaysRemaining: Int = 1,
        isGracePeriodActive: Bool = false,
        totalWorkoutDays: Int = 0,
        totalNutritionDays: Int = 0,
        createdAt: Date = Date(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.currentWorkoutStreak = currentWorkoutStreak
        self.currentNutritionStreak = currentNutritionStreak
        self.currentCombinedStreak = currentCombinedStreak
        self.longestWorkoutStreak = longestWorkoutStreak
        self.longestNutritionStreak = longestNutritionStreak
        self.longestCombinedStreak = longestCombinedStreak
        self.lastWorkoutDate = lastWorkoutDate
        self.lastNutritionDate = lastNutritionDate
        self.workoutStreakStartDate = workoutStreakStartDate
        self.nutritionStreakStartDate = nutritionStreakStartDate
        self.graceDaysRemaining = graceDaysRemaining
        self.isGracePeriodActive = isGracePeriodActive
        self.totalWorkoutDays = totalWorkoutDays
        self.totalNutritionDays = totalNutritionDays
        self.createdAt = createdAt
        self.lastUpdated = lastUpdated
    }
    
    // MARK: - Streak Management
    
    /// Record a workout for today
    func recordWorkout() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if already recorded today
        if let last = lastWorkoutDate, Calendar.current.isDate(last, inSameDayAs: today) {
            return // Already recorded today
        }
        
        // Check if streak continues or breaks
        if let last = lastWorkoutDate {
            let daysSinceLast = Calendar.current.dateComponents([.day], from: last, to: today).day ?? 0
            
            if daysSinceLast == 1 {
                // Consecutive day - continue streak
                currentWorkoutStreak += 1
            } else if daysSinceLast == 2 && graceDaysRemaining > 0 {
                // Missed one day but grace period applies
                graceDaysRemaining -= 1
                isGracePeriodActive = true
                currentWorkoutStreak += 1
            } else {
                // Streak broken - start new
                currentWorkoutStreak = 1
                workoutStreakStartDate = today
                graceDaysRemaining = 1 // Reset grace
                isGracePeriodActive = false
            }
        } else {
            // First workout ever
            currentWorkoutStreak = 1
            workoutStreakStartDate = today
        }
        
        lastWorkoutDate = today
        totalWorkoutDays += 1
        
        // Update best streak
        if currentWorkoutStreak > longestWorkoutStreak {
            longestWorkoutStreak = currentWorkoutStreak
        }
        
        updateCombinedStreak()
        lastUpdated = Date()
    }
    
    /// Record nutrition logging for today
    func recordNutrition() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if already recorded today
        if let last = lastNutritionDate, Calendar.current.isDate(last, inSameDayAs: today) {
            return // Already recorded today
        }
        
        // Check if streak continues or breaks
        if let last = lastNutritionDate {
            let daysSinceLast = Calendar.current.dateComponents([.day], from: last, to: today).day ?? 0
            
            if daysSinceLast == 1 {
                currentNutritionStreak += 1
            } else if daysSinceLast == 2 && graceDaysRemaining > 0 {
                graceDaysRemaining -= 1
                isGracePeriodActive = true
                currentNutritionStreak += 1
            } else {
                currentNutritionStreak = 1
                nutritionStreakStartDate = today
                graceDaysRemaining = 1
                isGracePeriodActive = false
            }
        } else {
            currentNutritionStreak = 1
            nutritionStreakStartDate = today
        }
        
        lastNutritionDate = today
        totalNutritionDays += 1
        
        if currentNutritionStreak > longestNutritionStreak {
            longestNutritionStreak = currentNutritionStreak
        }
        
        updateCombinedStreak()
        lastUpdated = Date()
    }
    
    private func updateCombinedStreak() {
        // Combined streak is the minimum of both streaks
        currentCombinedStreak = min(currentWorkoutStreak, currentNutritionStreak)
        
        if currentCombinedStreak > longestCombinedStreak {
            longestCombinedStreak = currentCombinedStreak
        }
    }
    
    /// Check and update streaks at app launch (handle missed days)
    func checkStreakStatus() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check workout streak
        if let last = lastWorkoutDate {
            let daysSinceLast = Calendar.current.dateComponents([.day], from: last, to: today).day ?? 0
            
            if daysSinceLast > 2 || (daysSinceLast == 2 && graceDaysRemaining == 0) {
                // Streak is broken
                currentWorkoutStreak = 0
                workoutStreakStartDate = nil
            }
        }
        
        // Check nutrition streak
        if let last = lastNutritionDate {
            let daysSinceLast = Calendar.current.dateComponents([.day], from: last, to: today).day ?? 0
            
            if daysSinceLast > 2 || (daysSinceLast == 2 && graceDaysRemaining == 0) {
                currentNutritionStreak = 0
                nutritionStreakStartDate = nil
            }
        }
        
        updateCombinedStreak()
        lastUpdated = Date()
    }
}

// MARK: - Streak Milestone

struct StreakMilestone {
    let days: Int
    let name: String
    let icon: String
    let description: String
    
    static let milestones: [StreakMilestone] = [
        StreakMilestone(days: 3, name: "Getting Started", icon: "flame", description: "3 days in a row!"),
        StreakMilestone(days: 7, name: "One Week", icon: "flame.fill", description: "A full week of consistency!"),
        StreakMilestone(days: 14, name: "Two Weeks", icon: "star", description: "Two weeks strong!"),
        StreakMilestone(days: 21, name: "Habit Forming", icon: "star.fill", description: "21 days - building a habit!"),
        StreakMilestone(days: 30, name: "One Month", icon: "crown", description: "A whole month! Incredible!"),
        StreakMilestone(days: 60, name: "Two Months", icon: "crown.fill", description: "60 days of dedication!"),
        StreakMilestone(days: 90, name: "Quarter Master", icon: "trophy", description: "90 days - you're unstoppable!"),
        StreakMilestone(days: 180, name: "Half Year Hero", icon: "medal", description: "6 months of consistency!"),
        StreakMilestone(days: 365, name: "Yearly Legend", icon: "medal.fill", description: "A full year! Legendary!")
    ]
    
    static func currentMilestone(for streak: Int) -> StreakMilestone? {
        milestones.filter { $0.days <= streak }.last
    }
    
    static func nextMilestone(for streak: Int) -> StreakMilestone? {
        milestones.first { $0.days > streak }
    }
    
    static func daysToNext(for streak: Int) -> Int? {
        guard let next = nextMilestone(for: streak) else { return nil }
        return next.days - streak
    }
}
