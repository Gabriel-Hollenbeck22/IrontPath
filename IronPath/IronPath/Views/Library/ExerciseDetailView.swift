//
//  ExerciseDetailView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                // Exercise Info
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text(exercise.name)
                        .font(.title)
                    
                    HStack(spacing: Spacing.sm) {
                        Label(exercise.muscleGroup.displayName, systemImage: "figure.strengthtraining.traditional")
                        Text("•")
                        Label(exercise.equipment.displayName, systemImage: "dumbbell.fill")
                        if exercise.isCompound {
                            Text("• Compound")
                        }
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }
                
                // Instructions
                if let instructions = exercise.instructions {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Instructions")
                            .font(.headline)
                        
                        Text(instructions)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(
            exercise: Exercise(
                name: "Barbell Bench Press",
                muscleGroup: .chest,
                equipment: .barbell,
                isCompound: true,
                instructions: "Lie on flat bench. Lower bar to chest, press up to full extension."
            )
        )
    }
}

