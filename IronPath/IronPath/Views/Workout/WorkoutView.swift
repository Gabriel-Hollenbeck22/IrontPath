//
//  WorkoutView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var workoutManager: WorkoutManager?
    @State private var isWorkoutActive = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isWorkoutActive {
                    if let manager = workoutManager, let workout = manager.activeWorkout {
                        WorkoutSessionView(workout: workout, manager: manager)
                    } else {
                        ContentUnavailableView(
                            "No Active Workout",
                            systemImage: "dumbbell.fill",
                            description: Text("Something went wrong")
                        )
                    }
                } else {
                    workoutStartView
                }
            }
            .onChange(of: workoutManager?.isWorkoutActive) { _, newValue in
                isWorkoutActive = newValue ?? false
            }
        }
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            workoutManager = WorkoutManager(modelContext: modelContext)
            isWorkoutActive = workoutManager?.isWorkoutActive ?? false
        }
    }
    
    private var workoutStartView: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 80))
                .foregroundStyle(.ironPathPrimary)
            
            Text("Ready to Train?")
                .font(.title)
            
            Text("Start a new workout session")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: startWorkout) {
                Label("Start Workout", systemImage: "play.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.ironPathPrimary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding()
    }
    
    private func startWorkout() {
        guard let manager = workoutManager else { return }
        let workout = manager.startWorkout(name: "Workout")
        isWorkoutActive = true
        HapticManager.mediumImpact()
    }
}

#Preview {
    WorkoutView()
        .modelContainer(for: Workout.self, inMemory: true)
}

