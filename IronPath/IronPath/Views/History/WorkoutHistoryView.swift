//
//  WorkoutHistoryView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Query(
        filter: #Predicate<Workout> { $0.isCompleted },
        sort: [SortDescriptor(\.date, order: .reverse)]
    ) private var workouts: [Workout]
    
    var body: some View {
        NavigationStack {
            Group {
                if workouts.isEmpty {
                    ContentUnavailableView(
                        "No Workouts Yet",
                        systemImage: "dumbbell.fill",
                        description: Text("Complete your first workout to see your history here")
                    )
                } else {
                    List {
                        ForEach(workouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                WorkoutHistoryRow(workout: workout)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Workout History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WorkoutHistoryRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(workout.name)
                .font(.headline)
            
            HStack {
                Text(FormatHelpers.date(workout.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if let volume = workout.sets?.reduce(0, { $0 + $1.volume }) {
                    Text(FormatHelpers.weight(volume))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    WorkoutHistoryView()
        .modelContainer(for: Workout.self, inMemory: true)
}

