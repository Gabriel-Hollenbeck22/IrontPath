//
//  WorkoutSessionView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI
import SwiftData
import Combine

struct WorkoutSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let workout: Workout
    let manager: WorkoutManager
    
    @State private var selectedExercise: Exercise?
    @State private var showingExercisePicker = false
    @State private var showingSetLogger = false
    @State private var showingSummary = false
    @State private var currentTime = Date()
    @State private var showCelebration = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Workout Header
                workoutHeader
                
                // Exercise List
                if let sets = workout.sets, !sets.isEmpty {
                    exerciseListSection(sets: sets)
                }
                
                // Add Exercise Button
                addExerciseButton
                
                // Complete Workout Button
                completeWorkoutButton
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.lg)
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    manager.cancelWorkout()
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView { exercise in
                selectedExercise = exercise
                showingExercisePicker = false
                showingSetLogger = true
            }
        }
        .sheet(isPresented: $showingSetLogger) {
            if let exercise = selectedExercise {
                SetLoggerView(
                    exercise: exercise,
                    workout: workout,
                    manager: manager
                )
            }
        }
        .sheet(isPresented: $showingSummary) {
            WorkoutSummaryView(workout: workout, manager: manager)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            currentTime = Date()
        }
        .celebrationOverlay(isPresented: $showCelebration, type: .workoutComplete)
    }
    
    private var workoutHeader: some View {
        let liveSeconds = Int(currentTime.timeIntervalSince(workout.startTime))
        let volume = workout.sets?.reduce(0.0) { $0 + $1.volume } ?? 0
        
        return VStack(spacing: Spacing.sm) {
            Text("Duration: \(FormatHelpers.duration(liveSeconds))")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Text("Total Volume: \(FormatHelpers.weight(volume))")
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .premiumCard()
    }
    
    private func exerciseListSection(sets: [WorkoutSet]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Exercises")
                .font(.headline)
            
            // Group sets by exercise
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
    
    private var addExerciseButton: some View {
        Button {
            HapticManager.mediumImpact()
            showingExercisePicker = true
        } label: {
            Label("Add Exercise", systemImage: "plus.circle.fill")
        }
        .neonGlowButton()
    }
    
    private var completeWorkoutButton: some View {
        Button {
            do {
                try manager.completeWorkout()
                // Show celebration first, then summary
                showCelebration = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    showCelebration = false
                    showingSummary = true
                }
            } catch {
                print("Error completing workout: \(error)")
            }
        } label: {
            Label("Complete Workout", systemImage: "checkmark.circle.fill")
        }
        .neonGlowButton(color: .ironPathSuccess)
    }
}

// MARK: - Exercise Sets View

struct ExerciseSetsView: View {
    let exercise: Exercise
    let sets: [WorkoutSet]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(exercise.name)
                .font(.headline)
            
            ForEach(sets.sorted(by: { $0.setNumber < $1.setNumber })) { set in
                HStack {
                    Text("Set \(set.setNumber)")
                        .font(.body)
                    
                    Spacer()
                    
                    Text("\(FormatHelpers.weight(set.weight)) × \(set.reps) reps")
                        .font(.body)
                    
                    if let rpe = set.rpe {
                        Text("RPE \(rpe)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, Spacing.sm)
            }
        }
        .nestedCard()
    }
}

#Preview {
    NavigationStack {
        WorkoutSessionView(
            workout: Workout(name: "Push Day"),
            manager: WorkoutManager(modelContext: try! ModelContext(ModelContainer(for: Workout.self)))
        )
    }
}

