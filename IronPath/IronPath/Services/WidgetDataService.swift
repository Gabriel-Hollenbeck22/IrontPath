//
//  WidgetDataService.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import Foundation
import SwiftData
import WidgetKit

/// Service to sync app data to App Groups for widget consumption
final class WidgetDataService {
    static let shared = WidgetDataService()
    
    private let suiteName = "group.com.ironpath.shared"
    private var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    private init() {}
    
    // MARK: - Streak Data
    
    func syncStreakData(workoutStreak: Int, nutritionStreak: Int, combinedStreak: Int) {
        defaults?.set(workoutStreak, forKey: "workoutStreak")
        defaults?.set(nutritionStreak, forKey: "nutritionStreak")
        defaults?.set(combinedStreak, forKey: "combinedStreak")
        
        // Trigger widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "StreakWidget")
    }
    
    func syncStreakData(from streakData: StreakData) {
        syncStreakData(
            workoutStreak: streakData.currentWorkoutStreak,
            nutritionStreak: streakData.currentNutritionStreak,
            combinedStreak: streakData.currentCombinedStreak
        )
    }
    
    // MARK: - Nutrition Data
    
    func syncTodayNutrition(
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double
    ) {
        defaults?.set(calories, forKey: "todayCalories")
        defaults?.set(protein, forKey: "todayProtein")
        defaults?.set(carbs, forKey: "todayCarbs")
        defaults?.set(fat, forKey: "todayFat")
        
        // Trigger widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "TodayProgressWidget")
    }
    
    func syncTodayNutrition(from summary: DailySummary) {
        syncTodayNutrition(
            calories: summary.totalCalories,
            protein: summary.totalProtein,
            carbs: summary.totalCarbs,
            fat: summary.totalFat
        )
    }
    
    // MARK: - User Targets
    
    func syncUserTargets(
        calorieTarget: Double,
        proteinTarget: Double,
        carbTarget: Double,
        fatTarget: Double
    ) {
        defaults?.set(calorieTarget, forKey: "calorieTarget")
        defaults?.set(proteinTarget, forKey: "proteinTarget")
        defaults?.set(carbTarget, forKey: "carbTarget")
        defaults?.set(fatTarget, forKey: "fatTarget")
        
        // Trigger widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "TodayProgressWidget")
    }
    
    func syncUserTargets(from profile: UserProfile) {
        syncUserTargets(
            calorieTarget: profile.targetCalories,
            proteinTarget: profile.targetProtein,
            carbTarget: profile.targetCarbs,
            fatTarget: profile.targetFat
        )
    }
    
    // MARK: - Full Sync
    
    func syncAllData(
        profile: UserProfile?,
        todaySummary: DailySummary?,
        streakData: StreakData?
    ) {
        if let profile = profile {
            syncUserTargets(from: profile)
        }
        
        if let summary = todaySummary {
            syncTodayNutrition(from: summary)
        }
        
        if let streak = streakData {
            syncStreakData(from: streak)
        }
    }
    
    // MARK: - Widget Refresh
    
    func refreshAllWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Convenience Extensions

extension DailySummary {
    func syncToWidget() {
        WidgetDataService.shared.syncTodayNutrition(from: self)
    }
}

extension StreakData {
    func syncToWidget() {
        WidgetDataService.shared.syncStreakData(from: self)
    }
}

extension UserProfile {
    func syncToWidget() {
        WidgetDataService.shared.syncUserTargets(from: self)
    }
}
