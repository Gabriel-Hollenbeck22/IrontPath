//
//  TemplateLoader.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import Foundation
import SwiftData

/// Loads built-in workout templates from JSON
enum TemplateLoader {
    
    // MARK: - JSON Structures
    
    private struct TemplatesJSON: Codable {
        let templates: [TemplateJSON]
    }
    
    private struct TemplateJSON: Codable {
        let name: String
        let description: String?
        let exercises: [TemplateExerciseJSON]
    }
    
    private struct TemplateExerciseJSON: Codable {
        let name: String
        let sets: Int
        let reps: String
        let rest: Int
        let notes: String?
    }
    
    // MARK: - Import Methods
    
    /// Import built-in templates if they haven't been loaded yet
    static func importTemplatesIfNeeded(modelContext: ModelContext) {
        // Check if templates already exist
        let descriptor = FetchDescriptor<WorkoutTemplate>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )
        
        do {
            let existingTemplates = try modelContext.fetch(descriptor)
            if existingTemplates.isEmpty {
                importTemplates(modelContext: modelContext)
            }
        } catch {
            print("Error checking existing templates: \(error)")
        }
    }
    
    /// Force import all templates (useful for updates)
    static func importTemplates(modelContext: ModelContext) {
        guard let url = Bundle.main.url(forResource: "WorkoutTemplates", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not load WorkoutTemplates.json")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let templatesData = try decoder.decode(TemplatesJSON.self, from: data)
            
            for (index, templateJSON) in templatesData.templates.enumerated() {
                let template = WorkoutTemplate(
                    name: templateJSON.name,
                    templateDescription: templateJSON.description,
                    isBuiltIn: true
                )
                
                modelContext.insert(template)
                
                // Create template exercises
                for (exerciseIndex, exerciseJSON) in templateJSON.exercises.enumerated() {
                    let templateExercise = TemplateExercise(
                        exerciseName: exerciseJSON.name,
                        targetSets: exerciseJSON.sets,
                        targetReps: exerciseJSON.reps,
                        restSeconds: exerciseJSON.rest,
                        notes: exerciseJSON.notes,
                        orderIndex: exerciseIndex
                    )
                    
                    // Link to template
                    templateExercise.template = template
                    
                    // Try to find the matching Exercise in the database
                    let exerciseDescriptor = FetchDescriptor<Exercise>(
                        predicate: #Predicate { exercise in
                            exercise.name == exerciseJSON.name
                        }
                    )
                    
                    if let exercise = try? modelContext.fetch(exerciseDescriptor).first {
                        templateExercise.exercise = exercise
                    }
                    
                    modelContext.insert(templateExercise)
                }
                
                print("Loaded template: \(templateJSON.name) (#\(index + 1))")
            }
            
            try modelContext.save()
            print("Successfully imported \(templatesData.templates.count) workout templates")
            
        } catch {
            print("Error importing workout templates: \(error)")
        }
    }
    
    /// Link template exercises to actual Exercise objects (call after exercises are loaded)
    static func linkExercises(modelContext: ModelContext) {
        let templateExerciseDescriptor = FetchDescriptor<TemplateExercise>(
            predicate: #Predicate { $0.exercise == nil }
        )
        
        do {
            let unlinkedExercises = try modelContext.fetch(templateExerciseDescriptor)
            
            for templateExercise in unlinkedExercises {
                guard let exerciseName = templateExercise.exerciseName else { continue }
                
                let exerciseDescriptor = FetchDescriptor<Exercise>(
                    predicate: #Predicate { exercise in
                        exercise.name == exerciseName
                    }
                )
                
                if let exercise = try modelContext.fetch(exerciseDescriptor).first {
                    templateExercise.exercise = exercise
                }
            }
            
            try modelContext.save()
            
        } catch {
            print("Error linking template exercises: \(error)")
        }
    }
}
