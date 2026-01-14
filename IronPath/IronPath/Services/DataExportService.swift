//
//  DataExportService.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import Foundation
import SwiftData

/// Service for exporting app data to CSV format
final class DataExportService {
    private let modelContext: ModelContext
    private let dateFormatter: DateFormatter
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    // MARK: - Workout Export
    
    func exportWorkouts() throws -> URL {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.isCompleted },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let workouts = try modelContext.fetch(descriptor)
        
        var csv = "Date,Name,Duration (min),Total Volume (lbs),Sets,Exercises\n"
        
        for workout in workouts {
            let date = dateFormatter.string(from: workout.date)
            let name = workout.name.replacingOccurrences(of: ",", with: ";")
            let duration = workout.durationSeconds / 60
            let volume = Int(workout.totalVolume)
            let setCount = workout.sets?.count ?? 0
            
            // Get unique exercise names
            let exercises = Set(workout.sets?.compactMap { $0.exercise?.name } ?? [])
                .joined(separator: "; ")
            
            csv += "\(date),\(name),\(duration),\(volume),\(setCount),\"\(exercises)\"\n"
        }
        
        return try saveCSV(csv, filename: "ironpath_workouts")
    }
    
    func exportWorkoutSets() throws -> URL {
        let descriptor = FetchDescriptor<WorkoutSet>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let sets = try modelContext.fetch(descriptor)
        
        var csv = "Date,Workout,Exercise,Muscle Group,Set #,Weight (lbs),Reps,RPE,Volume\n"
        
        for set in sets {
            let date = dateFormatter.string(from: set.timestamp)
            let workout = set.workout?.name.replacingOccurrences(of: ",", with: ";") ?? "Unknown"
            let exercise = set.exercise?.name.replacingOccurrences(of: ",", with: ";") ?? "Unknown"
            let muscleGroup = set.exercise?.muscleGroup.displayName ?? "Unknown"
            let setNumber = set.setNumber
            let weight = Int(set.weight)
            let reps = set.reps
            let rpe = set.rpe.map { String($0) } ?? ""
            let volume = Int(set.volume)
            
            csv += "\(date),\(workout),\(exercise),\(muscleGroup),\(setNumber),\(weight),\(reps),\(rpe),\(volume)\n"
        }
        
        return try saveCSV(csv, filename: "ironpath_workout_sets")
    }
    
    // MARK: - Nutrition Export
    
    func exportNutritionLog() throws -> URL {
        let descriptor = FetchDescriptor<LoggedFood>(
            sortBy: [SortDescriptor(\.loggedAt, order: .reverse)]
        )
        let foods = try modelContext.fetch(descriptor)
        
        var csv = "Date,Meal,Food,Brand,Servings,Calories,Protein (g),Carbs (g),Fat (g)\n"
        
        for food in foods {
            let date = dateFormatter.string(from: food.loggedAt)
            let meal = food.mealType.displayName
            let name = food.foodItem?.name.replacingOccurrences(of: ",", with: ";") ?? "Unknown"
            let brand = food.foodItem?.brand?.replacingOccurrences(of: ",", with: ";") ?? ""
            let servingGrams = String(format: "%.1f", food.servingSizeGrams)
            let calories = Int(food.calories)
            let protein = String(format: "%.1f", food.protein)
            let carbs = String(format: "%.1f", food.carbs)
            let fat = String(format: "%.1f", food.fat)
            
            csv += "\(date),\(meal),\(name),\(brand),\(servingGrams)g,\(calories),\(protein),\(carbs),\(fat)\n"
        }
        
        return try saveCSV(csv, filename: "ironpath_nutrition")
    }
    
    func exportDailySummaries() throws -> URL {
        let descriptor = FetchDescriptor<DailySummary>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let summaries = try modelContext.fetch(descriptor)
        
        var csv = "Date,Calories,Protein (g),Carbs (g),Fat (g),Sleep (hrs),Recovery Score,Workout Volume\n"
        
        for summary in summaries {
            let date = dateFormatter.string(from: summary.date)
            let calories = Int(summary.totalCalories)
            let protein = String(format: "%.1f", summary.totalProtein)
            let carbs = String(format: "%.1f", summary.totalCarbs)
            let fat = String(format: "%.1f", summary.totalFat)
            let sleep = summary.sleepHours.map { String(format: "%.1f", $0) } ?? ""
            let recovery = String(format: "%.1f", summary.recoveryScore)
            let volume = Int(summary.totalWorkoutVolume)
            
            csv += "\(date),\(calories),\(protein),\(carbs),\(fat),\(sleep),\(recovery),\(volume)\n"
        }
        
        return try saveCSV(csv, filename: "ironpath_daily_summaries")
    }
    
    // MARK: - Weight Export
    
    func exportWeightHistory() throws -> URL {
        let descriptor = FetchDescriptor<WeightEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let entries = try modelContext.fetch(descriptor)
        
        var csv = "Date,Weight (lbs),Body Fat (%),Notes\n"
        
        for entry in entries {
            let date = dateFormatter.string(from: entry.date)
            let weight = String(format: "%.1f", entry.weight)
            let bodyFat = entry.bodyFatPercentage.map { String(format: "%.1f", $0) } ?? ""
            let notes = entry.notes?.replacingOccurrences(of: ",", with: ";").replacingOccurrences(of: "\n", with: " ") ?? ""
            
            csv += "\(date),\(weight),\(bodyFat),\"\(notes)\"\n"
        }
        
        return try saveCSV(csv, filename: "ironpath_weight_history")
    }
    
    // MARK: - All Data Export
    
    func exportAllData() throws -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let exportDirectory = tempDirectory.appendingPathComponent("IronPath_Export_\(formattedDate())")
        
        try FileManager.default.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
        
        // Export each type
        let workoutsURL = try exportWorkouts()
        let setsURL = try exportWorkoutSets()
        let nutritionURL = try exportNutritionLog()
        let summariesURL = try exportDailySummaries()
        let weightURL = try exportWeightHistory()
        
        // Move files to export directory
        let files = [
            ("workouts.csv", workoutsURL),
            ("workout_sets.csv", setsURL),
            ("nutrition.csv", nutritionURL),
            ("daily_summaries.csv", summariesURL),
            ("weight_history.csv", weightURL)
        ]
        
        for (filename, sourceURL) in files {
            let destURL = exportDirectory.appendingPathComponent(filename)
            try? FileManager.default.copyItem(at: sourceURL, to: destURL)
        }
        
        // Create README
        let readme = """
        IronPath Data Export
        ====================
        
        Exported on: \(formattedDate())
        
        Files included:
        - workouts.csv: Completed workout summaries
        - workout_sets.csv: Individual set data
        - nutrition.csv: Logged food items
        - daily_summaries.csv: Daily nutrition and recovery summaries
        - weight_history.csv: Body weight tracking
        
        All dates are in UTC.
        All weights are in pounds (lbs).
        All macros are in grams (g).
        """
        
        let readmeURL = exportDirectory.appendingPathComponent("README.txt")
        try readme.write(to: readmeURL, atomically: true, encoding: .utf8)
        
        return exportDirectory
    }
    
    // MARK: - Helpers
    
    private func saveCSV(_ content: String, filename: String) throws -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("\(filename)_\(formattedDate()).csv")
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        return fileURL
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// MARK: - Export Type

enum ExportType: String, CaseIterable, Identifiable {
    case workouts = "Workouts"
    case workoutSets = "Workout Sets"
    case nutrition = "Nutrition Log"
    case dailySummaries = "Daily Summaries"
    case weight = "Weight History"
    case all = "All Data"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .workouts: return "figure.strengthtraining.traditional"
        case .workoutSets: return "list.bullet"
        case .nutrition: return "fork.knife"
        case .dailySummaries: return "calendar"
        case .weight: return "scalemass.fill"
        case .all: return "square.and.arrow.up.on.square"
        }
    }
    
    var description: String {
        switch self {
        case .workouts: return "Completed workout summaries"
        case .workoutSets: return "Individual set data with exercise details"
        case .nutrition: return "All logged food items with macros"
        case .dailySummaries: return "Daily totals and recovery scores"
        case .weight: return "Body weight tracking history"
        case .all: return "Complete data export (ZIP folder)"
        }
    }
}
