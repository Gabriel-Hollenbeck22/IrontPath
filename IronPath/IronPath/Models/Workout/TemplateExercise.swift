//
//  TemplateExercise.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import Foundation
import SwiftData

@Model
final class TemplateExercise {
    var id: UUID
    var targetSets: Int
    var targetReps: String  // Format: "8-12" or "10" or "AMRAP"
    var restSeconds: Int
    var notes: String?
    var orderIndex: Int
    
    // Store exercise name for built-in templates (before Exercise is linked)
    var exerciseName: String?
    
    @Relationship(deleteRule: .nullify)
    var exercise: Exercise?
    
    @Relationship(deleteRule: .nullify, inverse: \WorkoutTemplate.exercises)
    var template: WorkoutTemplate?
    
    init(
        id: UUID = UUID(),
        exercise: Exercise? = nil,
        exerciseName: String? = nil,
        targetSets: Int = 3,
        targetReps: String = "8-12",
        restSeconds: Int = 90,
        notes: String? = nil,
        orderIndex: Int = 0
    ) {
        self.id = id
        self.exercise = exercise
        self.exerciseName = exerciseName ?? exercise?.name
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.restSeconds = restSeconds
        self.notes = notes
        self.orderIndex = orderIndex
    }
    
    /// Display name for the exercise
    var displayName: String {
        exercise?.name ?? exerciseName ?? "Unknown Exercise"
    }
    
    /// Parse target reps to get min value (for suggestions)
    var minReps: Int {
        if targetReps.lowercased() == "amrap" {
            return 8
        }
        
        let components = targetReps.components(separatedBy: "-")
        return Int(components.first ?? "8") ?? 8
    }
    
    /// Parse target reps to get max value
    var maxReps: Int {
        if targetReps.lowercased() == "amrap" {
            return 20
        }
        
        let components = targetReps.components(separatedBy: "-")
        if components.count > 1 {
            return Int(components[1]) ?? 12
        }
        return Int(components.first ?? "12") ?? 12
    }
}
