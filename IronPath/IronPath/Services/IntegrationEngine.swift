//
//  IntegrationEngine.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import Foundation
import SwiftData

@Observable
final class IntegrationEngine {
    private let modelContext: ModelContext
    
    // Current state
    var currentRecoveryScore: Double = 0
    var activeSuggestions: [SmartSuggestion] = []
    var correlationData: CorrelationData?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Recovery Score Calculation
    
    /// Calculate recovery score based on sleep, protein, and rest
    /// Formula: (SleepFactor * 0.4) + (ProteinFactor * 0.35) + (RestFactor * 0.25)
    func calculateRecoveryScore(
        for date: Date,
        profile: UserProfile,
        sleepHours: Double?,
        proteinIntake: Double?,
        lastWorkoutDate: Date?
    ) -> Double {
        // Sleep Factor
        let sleepFactor: Double
        if let sleepHours = sleepHours {
            sleepFactor = min(sleepHours / profile.sleepGoalHours, 1.0) * 100
        } else {
            sleepFactor = 50 // Assume average if no data
        }
        
        // Protein Factor
        let proteinFactor: Double
        if let proteinIntake = proteinIntake {
            proteinFactor = min(proteinIntake / profile.targetProtein, 1.0) * 100
        } else {
            proteinFactor = 50 // Assume average if no data
        }
        
        // Rest Factor
        let restFactor: Double
        if let lastWorkoutDate = lastWorkoutDate {
            let daysSinceWorkout = Calendar.current.dateComponents([.day], from: lastWorkoutDate, to: date).day ?? 0
            restFactor = daysSinceWorkout >= 1 ? 100 : 50
        } else {
            restFactor = 100 // Well rested if no recent workout
        }
        
        let recoveryScore = (sleepFactor * 0.4) + (proteinFactor * 0.35) + (restFactor * 0.25)
        currentRecoveryScore = recoveryScore
        
        return recoveryScore
    }
    
    /// Update recovery score in daily summary
    func updateDailySummaryRecoveryScore(for date: Date, profile: UserProfile) throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        let descriptor = FetchDescriptor<DailySummary>(
            predicate: #Predicate { summary in
                summary.date == startOfDay
            }
        )
        
        guard let summary = try modelContext.fetch(descriptor).first else {
            return
        }
        
        // Get last workout before this date
        let workoutDescriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { workout in
                workout.date < date && workout.isCompleted
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let lastWorkoutDate = try modelContext.fetch(workoutDescriptor).first?.date
        
        let recoveryScore = calculateRecoveryScore(
            for: date,
            profile: profile,
            sleepHours: summary.sleepHours,
            proteinIntake: summary.totalProtein,
            lastWorkoutDate: lastWorkoutDate
        )
        
        summary.recoveryScore = recoveryScore
        try modelContext.save()
    }
    
    // MARK: - Recovery Buffer Calculation
    
    /// Calculate macro adjustments based on workout volume
    func calculateRecoveryBuffer(for workout: Workout, profile: UserProfile) -> MacroAdjustment {
        let volumePercentile = calculateVolumePercentile(workout)
        
        // High volume workout (>80th percentile)
        if volumePercentile > 0.8 {
            let carbBoost = 40.0 * (volumePercentile - 0.8) / 0.2  // 0-40g scale
            let proteinBoost = 20.0 * (volumePercentile - 0.8) / 0.2  // 0-20g scale
            
            return MacroAdjustment(
                carbsAdjustment: carbBoost,
                proteinAdjustment: proteinBoost,
                fatAdjustment: 0,
                reason: .highVolumeRecovery
            )
        }
        
        return MacroAdjustment.none
    }
    
    private func calculateVolumePercentile(_ workout: Workout) -> Double {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.isCompleted }
        )
        
        do {
            let allWorkouts = try modelContext.fetch(descriptor)
            guard !allWorkouts.isEmpty else { return 0.5 }
            
            let sortedVolumes = allWorkouts.map { $0.totalVolume }.sorted()
            let workoutVolume = workout.totalVolume
            
            let lowerCount = sortedVolumes.filter { $0 < workoutVolume }.count
            return Double(lowerCount) / Double(sortedVolumes.count)
        } catch {
            print("Error calculating volume percentile: \(error)")
            return 0.5
        }
    }
    
    // MARK: - Smart Suggestions
    
    /// Generate contextual suggestions based on recent data
    func generateSuggestions(profile: UserProfile) async throws -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        // Get last 7 days of data
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let descriptor = FetchDescriptor<DailySummary>(
            predicate: #Predicate { summary in
                summary.date >= sevenDaysAgo
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let recentSummaries = try modelContext.fetch(descriptor)
        
        // Check for strength plateau + caloric deficit
        if let plateauSuggestion = try checkStrengthPlateau(profile: profile, summaries: recentSummaries) {
            suggestions.append(plateauSuggestion)
        }
        
        // Check for insufficient protein
        if let proteinSuggestion = checkProteinIntake(profile: profile, summaries: recentSummaries) {
            suggestions.append(proteinSuggestion)
        }
        
        // Check for poor sleep + workout planned
        if let sleepSuggestion = checkSleepRecovery(profile: profile, summaries: recentSummaries) {
            suggestions.append(sleepSuggestion)
        }
        
        // Check for muscle group recovery
        if let muscleRecoverySuggestion = try checkMuscleGroupRecovery() {
            suggestions.append(muscleRecoverySuggestion)
        }
        
        // Check for progressive overload opportunities
        if let overloadSuggestion = try checkProgressiveOverload() {
            suggestions.append(overloadSuggestion)
        }
        
        // Check for deload week recommendation
        if let deloadSuggestion = try checkDeloadRecommendation(summaries: recentSummaries) {
            suggestions.append(deloadSuggestion)
        }
        
        // Check for carb timing around workouts
        if let carbTimingSuggestion = checkCarbTiming(profile: profile, summaries: recentSummaries) {
            suggestions.append(carbTimingSuggestion)
        }
        
        // Check for creatine timing (if high intensity training)
        if let creatineSuggestion = try checkCreatineRecommendation() {
            suggestions.append(creatineSuggestion)
        }
        
        activeSuggestions = suggestions
        return suggestions
    }
    
    private func checkStrengthPlateau(profile: UserProfile, summaries: [DailySummary]) throws -> SmartSuggestion? {
        // Check if volume has been stagnant
        let volumes = summaries.compactMap { $0.totalWorkoutVolume }.filter { $0 > 0 }
        guard volumes.count >= 3 else { return nil }
        
        let recentAvg = volumes.prefix(3).reduce(0, +) / 3.0
        let olderAvg = volumes.dropFirst(3).prefix(3).reduce(0, +) / max(3.0, Double(volumes.dropFirst(3).prefix(3).count))
        
        // Volume hasn't increased and in caloric deficit
        if recentAvg <= olderAvg {
            let avgCalories = summaries.compactMap { $0.totalCalories }.reduce(0, +) / Double(summaries.count)
            let deficit = profile.targetCalories - avgCalories
            
            if deficit > 300 {
                return SmartSuggestion(
                    id: UUID(),
                    type: .nutrition,
                    priority: .high,
                    title: "Strength Plateau Detected",
                    message: "Your strength is plateauing, but you are in a \(Int(deficit))-calorie deficit. Consider increasing carbs by 40g on training days.",
                    actionable: true
                )
            }
        }
        
        return nil
    }
    
    private func checkProteinIntake(profile: UserProfile, summaries: [DailySummary]) -> SmartSuggestion? {
        let avgProtein = summaries.compactMap { $0.totalProtein }.reduce(0, +) / Double(summaries.count)
        
        // Check if protein is below 0.7g per lb bodyweight
        if let bodyWeight = profile.bodyWeight {
            let minProtein = bodyWeight * 0.7
            if avgProtein < minProtein {
                return SmartSuggestion(
                    id: UUID(),
                    type: .nutrition,
                    priority: .medium,
                    title: "Low Protein Intake",
                    message: "Protein intake below optimal for muscle synthesis. Target at least \(Int(minProtein))g daily.",
                    actionable: true
                )
            }
        }
        
        return nil
    }
    
    private func checkSleepRecovery(profile: UserProfile, summaries: [DailySummary]) -> SmartSuggestion? {
        guard let latestSummary = summaries.first,
              let sleepHours = latestSummary.sleepHours else {
            return nil
        }
        
        let sleepPercentage = sleepHours / profile.sleepGoalHours
        
        if sleepPercentage < 0.7 {
            return SmartSuggestion(
                id: UUID(),
                type: .recovery,
                priority: .high,
                title: "Low Sleep Detected",
                message: "Recovery Alert: Consider 10% volume reduction for safety. Sleep: \(String(format: "%.1f", sleepHours))hrs (goal: \(String(format: "%.1f", profile.sleepGoalHours))hrs)",
                actionable: true
            )
        }
        
        return nil
    }
    
    private func checkMuscleGroupRecovery() throws -> SmartSuggestion? {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { workout in
                workout.date >= yesterday && workout.isCompleted
            }
        )
        
        let recentWorkouts = try modelContext.fetch(descriptor)
        
        for workout in recentWorkouts {
            let volumeByMuscle = workout.volumeByMuscleGroup()
            
            // Check for high leg volume
            if let legVolume = volumeByMuscle[.quads], legVolume > 1000 { // threshold
                return SmartSuggestion(
                    id: UUID(),
                    type: .workout,
                    priority: .low,
                    title: "Leg Recovery in Progress",
                    message: "You had high leg volume yesterday. Upper body work recommended today.",
                    actionable: false
                )
            }
        }
        
        return nil
    }
    
    // MARK: - Progressive Overload Check
    
    private func checkProgressiveOverload() throws -> SmartSuggestion? {
        // Get recent workout sets to find exercises ready for progression
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        let setDescriptor = FetchDescriptor<WorkoutSet>(
            predicate: #Predicate { set in
                set.timestamp >= twoWeeksAgo
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        let recentSets = try modelContext.fetch(setDescriptor)
        
        // Group by exercise
        var exerciseSets: [UUID: [WorkoutSet]] = [:]
        for set in recentSets {
            if let exerciseId = set.exercise?.id {
                exerciseSets[exerciseId, default: []].append(set)
            }
        }
        
        // Find exercises where user hit target reps consistently
        for (_, sets) in exerciseSets {
            guard sets.count >= 3 else { continue }
            
            let recentThree = Array(sets.prefix(3))
            let allHitEightOrMore = recentThree.allSatisfy { $0.reps >= 8 }
            let sameWeight = Set(recentThree.map { $0.weight }).count == 1
            
            // User hit 8+ reps at same weight 3 times in a row
            if allHitEightOrMore && sameWeight, let exerciseName = sets.first?.exercise?.name {
                let currentWeight = recentThree.first!.weight
                let suggestedWeight = currentWeight + 5 // 5 lb increment
                
                return SmartSuggestion(
                    id: UUID(),
                    type: .workout,
                    priority: .medium,
                    title: "Time to Progress!",
                    message: "You've hit 8+ reps on \(exerciseName) three sessions in a row. Try \(Int(suggestedWeight)) lbs next time.",
                    actionable: true
                )
            }
        }
        
        return nil
    }
    
    // MARK: - Deload Recommendation
    
    private func checkDeloadRecommendation(summaries: [DailySummary]) throws -> SmartSuggestion? {
        // Check for 4+ weeks of consistent high volume training
        let fourWeeksAgo = Calendar.current.date(byAdding: .day, value: -28, to: Date())!
        let workoutDescriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { workout in
                workout.date >= fourWeeksAgo && workout.isCompleted
            }
        )
        
        let recentWorkouts = try modelContext.fetch(workoutDescriptor)
        
        // Count training days per week
        let calendar = Calendar.current
        var weeklyWorkouts: [Int: Int] = [:]
        
        for workout in recentWorkouts {
            let weekOfYear = calendar.component(.weekOfYear, from: workout.date)
            weeklyWorkouts[weekOfYear, default: 0] += 1
        }
        
        // If 4+ weeks of 4+ workouts per week
        let highVolumeWeeks = weeklyWorkouts.values.filter { $0 >= 4 }.count
        
        if highVolumeWeeks >= 4 {
            // Check if performance is declining
            let volumes = recentWorkouts.map { $0.totalVolume }
            if volumes.count >= 4 {
                let recentAvg = volumes.prefix(2).reduce(0, +) / 2.0
                let olderAvg = volumes.suffix(2).reduce(0, +) / 2.0
                
                if recentAvg < olderAvg * 0.9 { // 10% volume drop
                    return SmartSuggestion(
                        id: UUID(),
                        type: .recovery,
                        priority: .high,
                        title: "Deload Week Recommended",
                        message: "You've trained hard for 4+ weeks and performance is declining. Consider a deload week with 50% volume to optimize recovery.",
                        actionable: true
                    )
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Carb Timing Check
    
    private func checkCarbTiming(profile: UserProfile, summaries: [DailySummary]) -> SmartSuggestion? {
        guard let todaysSummary = summaries.first else { return nil }
        
        // Check if user has high workout volume but low carb intake
        let carbIntake = todaysSummary.totalCarbs
        let targetCarbs = profile.targetCarbs
        let workoutVolume = todaysSummary.totalWorkoutVolume
        
        // High volume day (>5000 lbs total) but carbs below 80% target
        if workoutVolume > 5000 && carbIntake < targetCarbs * 0.8 {
            return SmartSuggestion(
                id: UUID(),
                type: .nutrition,
                priority: .medium,
                title: "Fuel Your Training",
                message: "High volume workout today but carbs are low. Consider adding \(Int((targetCarbs - carbIntake) * 0.5))g carbs pre/post workout for better performance.",
                actionable: true
            )
        }
        
        return nil
    }
    
    // MARK: - Creatine Recommendation
    
    private func checkCreatineRecommendation() throws -> SmartSuggestion? {
        // Check for consistent strength training
        let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let workoutDescriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { workout in
                workout.date >= monthAgo && workout.isCompleted
            }
        )
        
        let recentWorkouts = try modelContext.fetch(workoutDescriptor)
        
        // If user has been training consistently (12+ workouts in a month)
        if recentWorkouts.count >= 12 {
            // Only show this suggestion occasionally (random chance)
            let shouldShow = Int.random(in: 0..<10) == 0
            
            if shouldShow {
                return SmartSuggestion(
                    id: UUID(),
                    type: .general,
                    priority: .low,
                    title: "Consider Creatine",
                    message: "You're training consistently! Creatine monohydrate (5g/day) is one of the most researched and effective supplements for strength and muscle gains.",
                    actionable: false
                )
            }
        }
        
        return nil
    }
    
    // MARK: - Correlation Analysis
    
    /// Generate correlation data for visualization
    func generateCorrelationData(days: Int = 7) throws -> CorrelationData {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        
        let descriptor = FetchDescriptor<DailySummary>(
            predicate: #Predicate { summary in
                summary.date >= startDate
            },
            sortBy: [SortDescriptor(\.date)]
        )
        
        let summaries = try modelContext.fetch(descriptor)
        
        var dataPoints: [CorrelationDataPoint] = []
        
        for summary in summaries {
            let point = CorrelationDataPoint(
                date: summary.date,
                proteinIntake: summary.totalProtein,
                calorieIntake: summary.totalCalories,
                workoutVolume: summary.totalWorkoutVolume,
                recoveryScore: summary.recoveryScore,
                sleepHours: summary.sleepHours
            )
            dataPoints.append(point)
        }
        
        let correlationData = CorrelationData(
            startDate: startDate,
            endDate: Date(),
            dataPoints: dataPoints
        )
        
        self.correlationData = correlationData
        return correlationData
    }
}

// MARK: - Supporting Types

struct MacroAdjustment {
    let carbsAdjustment: Double
    let proteinAdjustment: Double
    let fatAdjustment: Double
    let reason: AdjustmentReason
    
    static var none: MacroAdjustment {
        MacroAdjustment(carbsAdjustment: 0, proteinAdjustment: 0, fatAdjustment: 0, reason: .none)
    }
    
    var hasAdjustment: Bool {
        carbsAdjustment != 0 || proteinAdjustment != 0 || fatAdjustment != 0
    }
}

enum AdjustmentReason {
    case highVolumeRecovery
    case lowProtein
    case caloricDeficit
    case none
}

struct SmartSuggestion: Identifiable {
    let id: UUID
    let type: SuggestionType
    let priority: SuggestionPriority
    let title: String
    let message: String
    let actionable: Bool
}

enum SuggestionType {
    case nutrition
    case workout
    case recovery
    case general
}

enum SuggestionPriority {
    case low
    case medium
    case high
    
    var color: String {
        switch self {
        case .low: return "blue"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

struct CorrelationData {
    let startDate: Date
    let endDate: Date
    let dataPoints: [CorrelationDataPoint]
    
    var averageProtein: Double {
        let total = dataPoints.reduce(0) { $0 + $1.proteinIntake }
        return dataPoints.isEmpty ? 0 : total / Double(dataPoints.count)
    }
    
    var averageVolume: Double {
        let total = dataPoints.reduce(0) { $0 + $1.workoutVolume }
        return dataPoints.isEmpty ? 0 : total / Double(dataPoints.count)
    }
    
    var averageRecoveryScore: Double {
        let total = dataPoints.reduce(0) { $0 + $1.recoveryScore }
        return dataPoints.isEmpty ? 0 : total / Double(dataPoints.count)
    }
}

struct CorrelationDataPoint {
    let date: Date
    let proteinIntake: Double
    let calorieIntake: Double
    let workoutVolume: Double
    let recoveryScore: Double
    let sleepHours: Double?
}

