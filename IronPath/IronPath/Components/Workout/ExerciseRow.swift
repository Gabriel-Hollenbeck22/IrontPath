//
//  ExerciseRow.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.selection()
            onSelect()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: Spacing.sm) {
                        Text(exercise.muscleGroup.displayName)
                        Text("•")
                        Text(exercise.equipment.displayName)
                        if exercise.isCompound {
                            Text("• Compound")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(Spacing.cardPadding)
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        ExerciseRow(
            exercise: Exercise(
                name: "Barbell Bench Press",
                muscleGroup: .chest,
                equipment: .barbell,
                isCompound: true
            ),
            onSelect: {}
        )
    }
    .padding()
}

