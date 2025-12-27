//
//  ExercisePickerView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var exercises: [Exercise]
    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup?
    
    let onSelect: (Exercise) -> Void
    
    var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            (searchText.isEmpty || exercise.name.localizedStandardContains(searchText)) &&
            (selectedMuscleGroup == nil || exercise.muscleGroup == selectedMuscleGroup)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Muscle group filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            Button(group.displayName) {
                                selectedMuscleGroup = selectedMuscleGroup == group ? nil : group
                                HapticManager.selection()
                            }
                            .buttonStyle(.bordered)
                            .tint(selectedMuscleGroup == group ? .ironPathPrimary : .gray)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
                .background(Color(.secondarySystemBackground))
                
                // Exercise list
                List {
                    ForEach(filteredExercises) { exercise in
                        ExerciseRow(exercise: exercise) {
                            onSelect(exercise)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ExercisePickerView { _ in }
        .modelContainer(for: Exercise.self, inMemory: true)
}

