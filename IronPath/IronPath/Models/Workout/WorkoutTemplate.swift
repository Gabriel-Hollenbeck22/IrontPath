//
//  WorkoutTemplate.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import Foundation
import SwiftData

@Model
final class WorkoutTemplate {
    var id: UUID
    var name: String
    var templateDescription: String?
    var isBuiltIn: Bool
    var createdAt: Date
    var lastUsed: Date?
    var useCount: Int
    
    @Relationship(deleteRule: .cascade)
    var exercises: [TemplateExercise]?
    
    init(
        id: UUID = UUID(),
        name: String,
        templateDescription: String? = nil,
        isBuiltIn: Bool = false,
        createdAt: Date = Date(),
        lastUsed: Date? = nil,
        useCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.templateDescription = templateDescription
        self.isBuiltIn = isBuiltIn
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.useCount = useCount
    }
    
    /// Get exercises sorted by order index
    var sortedExercises: [TemplateExercise] {
        (exercises ?? []).sorted { $0.orderIndex < $1.orderIndex }
    }
    
    /// Estimated workout duration in minutes
    var estimatedDuration: Int {
        guard let exercises = exercises else { return 0 }
        
        var totalMinutes = 0
        for exercise in exercises {
            // Estimate 45 seconds per set + rest time
            let setTime = exercise.targetSets * 45 / 60
            let restTime = (exercise.targetSets - 1) * exercise.restSeconds / 60
            totalMinutes += setTime + restTime
        }
        
        return max(totalMinutes, exercises.count * 3) // Minimum 3 min per exercise
    }
    
    /// Total number of sets in template
    var totalSets: Int {
        (exercises ?? []).reduce(0) { $0 + $1.targetSets }
    }
    
    /// Unique muscle groups targeted
    var muscleGroups: [MuscleGroup] {
        let groups = Set((exercises ?? []).compactMap { $0.exercise?.muscleGroup })
        return Array(groups).sorted { $0.displayName < $1.displayName }
    }
}
