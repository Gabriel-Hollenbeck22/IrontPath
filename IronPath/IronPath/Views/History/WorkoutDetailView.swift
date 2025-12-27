//
//  WorkoutDetailView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(workout.name)
                        .font(.title)
                    
                    Text(FormatHelpers.date(workout.date))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                // Stats
                VStack(spacing: Spacing.sm) {
                    statRow(label: "Duration", value: FormatHelpers.duration(workout.durationSeconds))
                    statRow(label: "Total Volume", value: FormatHelpers.weight(workout.totalVolume))
                    statRow(label: "Sets", value: "\(workout.sets?.count ?? 0)")
                    
                    if let avgRPE = workout.averageRPE {
                        statRow(label: "Avg RPE", value: String(format: "%.1f", avgRPE))
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(16)
                
                // Exercises
                if let sets = workout.sets, !sets.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Exercises")
                            .font(.headline)
                        
                        let groupedSets = Dictionary(grouping: sets) { $0.exercise?.id ?? UUID() }
                        
                        ForEach(Array(groupedSets.keys), id: \.self) { exerciseId in
                            if let exerciseSets = groupedSets[exerciseId],
                               let exercise = exerciseSets.first?.exercise {
                                ExerciseSetsView(
                                    exercise: exercise,
                                    sets: exerciseSets
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: Workout(name: "Push Day"))
    }
}

