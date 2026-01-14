//
//  TemplateBuilderView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData

struct TemplateBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var existingTemplate: WorkoutTemplate?
    
    @State private var name: String = ""
    @State private var templateDescription: String = ""
    @State private var exercises: [TemplateExerciseEntry] = []
    @State private var showingExercisePicker = false
    
    private var isEditing: Bool { existingTemplate != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                // Template Info
                Section("Template Info") {
                    TextField("Name", text: $name)
                    
                    TextField("Description (optional)", text: $templateDescription, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                // Exercises
                Section {
                    if exercises.isEmpty {
                        ContentUnavailableView(
                            "No Exercises",
                            systemImage: "dumbbell.fill",
                            description: Text("Add exercises to your template")
                        )
                        .frame(height: 150)
                    } else {
                        ForEach($exercises) { $entry in
                            TemplateExerciseRow(entry: $entry)
                        }
                        .onDelete(perform: deleteExercises)
                        .onMove(perform: moveExercises)
                    }
                    
                    Button {
                        showingExercisePicker = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
                            .foregroundStyle(Color.ironPathPrimary)
                    }
                } header: {
                    HStack {
                        Text("Exercises")
                        Spacer()
                        if !exercises.isEmpty {
                            Text("\(exercises.count) exercises")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Summary
                if !exercises.isEmpty {
                    Section("Summary") {
                        HStack {
                            Text("Total Sets")
                            Spacer()
                            Text("\(totalSets)")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Estimated Duration")
                            Spacer()
                            Text("~\(estimatedDuration) min")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Template" : "New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .disabled(name.isEmpty || exercises.isEmpty)
                }
                
                if !exercises.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerForTemplate { exercise in
                    let entry = TemplateExerciseEntry(
                        exercise: exercise,
                        orderIndex: exercises.count
                    )
                    exercises.append(entry)
                }
            }
            .onAppear {
                loadExistingTemplate()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalSets: Int {
        exercises.reduce(0) { $0 + $1.targetSets }
    }
    
    private var estimatedDuration: Int {
        var totalMinutes = 0
        for exercise in exercises {
            let setTime = exercise.targetSets * 45 / 60
            let restTime = (exercise.targetSets - 1) * exercise.restSeconds / 60
            totalMinutes += setTime + restTime
        }
        return max(totalMinutes, exercises.count * 3)
    }
    
    // MARK: - Actions
    
    private func loadExistingTemplate() {
        guard let template = existingTemplate else { return }
        
        name = template.name
        templateDescription = template.templateDescription ?? ""
        
        exercises = template.sortedExercises.map { templateExercise in
            TemplateExerciseEntry(
                id: templateExercise.id,
                exercise: templateExercise.exercise,
                exerciseName: templateExercise.exerciseName,
                targetSets: templateExercise.targetSets,
                targetReps: templateExercise.targetReps,
                restSeconds: templateExercise.restSeconds,
                notes: templateExercise.notes,
                orderIndex: templateExercise.orderIndex
            )
        }
    }
    
    private func deleteExercises(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
        updateOrderIndices()
    }
    
    private func moveExercises(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
        updateOrderIndices()
    }
    
    private func updateOrderIndices() {
        for (index, _) in exercises.enumerated() {
            exercises[index].orderIndex = index
        }
    }
    
    private func saveTemplate() {
        if let existing = existingTemplate {
            // Update existing template
            existing.name = name
            existing.templateDescription = templateDescription.isEmpty ? nil : templateDescription
            
            // Remove old exercises
            if let oldExercises = existing.exercises {
                for exercise in oldExercises {
                    modelContext.delete(exercise)
                }
            }
            
            // Add new exercises
            for entry in exercises {
                let templateExercise = TemplateExercise(
                    exercise: entry.exercise,
                    exerciseName: entry.exercise?.name ?? entry.exerciseName,
                    targetSets: entry.targetSets,
                    targetReps: entry.targetReps,
                    restSeconds: entry.restSeconds,
                    notes: entry.notes,
                    orderIndex: entry.orderIndex
                )
                templateExercise.template = existing
                modelContext.insert(templateExercise)
            }
            
        } else {
            // Create new template
            let template = WorkoutTemplate(
                name: name,
                templateDescription: templateDescription.isEmpty ? nil : templateDescription,
                isBuiltIn: false
            )
            
            modelContext.insert(template)
            
            // Add exercises
            for entry in exercises {
                let templateExercise = TemplateExercise(
                    exercise: entry.exercise,
                    exerciseName: entry.exercise?.name ?? entry.exerciseName,
                    targetSets: entry.targetSets,
                    targetReps: entry.targetReps,
                    restSeconds: entry.restSeconds,
                    notes: entry.notes,
                    orderIndex: entry.orderIndex
                )
                templateExercise.template = template
                modelContext.insert(templateExercise)
            }
        }
        
        try? modelContext.save()
        HapticManager.success()
        dismiss()
    }
}

// MARK: - Template Exercise Entry (Local State)

struct TemplateExerciseEntry: Identifiable {
    var id: UUID = UUID()
    var exercise: Exercise?
    var exerciseName: String?
    var targetSets: Int = 3
    var targetReps: String = "8-12"
    var restSeconds: Int = 90
    var notes: String?
    var orderIndex: Int = 0
    
    var displayName: String {
        exercise?.name ?? exerciseName ?? "Unknown"
    }
}

// MARK: - Template Exercise Row

struct TemplateExerciseRow: View {
    @Binding var entry: TemplateExerciseEntry
    
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.displayName)
                        .font(.headline)
                    
                    Text("\(entry.targetSets) sets × \(entry.targetReps) reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    showingDetails.toggle()
                } label: {
                    Image(systemName: showingDetails ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if showingDetails {
                VStack(spacing: Spacing.sm) {
                    Stepper("Sets: \(entry.targetSets)", value: $entry.targetSets, in: 1...10)
                    
                    HStack {
                        Text("Reps")
                        Spacer()
                        TextField("Reps", text: $entry.targetReps)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .multilineTextAlignment(.center)
                    }
                    
                    Stepper("Rest: \(entry.restSeconds)s", value: $entry.restSeconds, in: 30...300, step: 15)
                    
                    TextField("Notes (optional)", text: Binding(
                        get: { entry.notes ?? "" },
                        set: { entry.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
                .padding(.top, Spacing.xs)
            }
        }
    }
}

// MARK: - Exercise Picker for Template

struct ExercisePickerForTemplate: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    
    var onSelect: (Exercise) -> Void
    
    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup?
    
    private var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            let matchesSearch = searchText.isEmpty || 
                exercise.name.localizedCaseInsensitiveContains(searchText)
            
            let matchesGroup = selectedMuscleGroup == nil || 
                exercise.muscleGroup == selectedMuscleGroup
            
            return matchesSearch && matchesGroup
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Muscle Group Filter
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedMuscleGroup == nil
                            ) {
                                selectedMuscleGroup = nil
                            }
                            
                            ForEach(MuscleGroup.allCases, id: \.self) { group in
                                FilterChip(
                                    title: group.displayName,
                                    isSelected: selectedMuscleGroup == group
                                ) {
                                    selectedMuscleGroup = group
                                }
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                // Exercises
                ForEach(filteredExercises) { exercise in
                    Button {
                        onSelect(exercise)
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Text(exercise.muscleGroup.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.ironPathPrimary)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? Color.ironPathPrimary : Color.secondary.opacity(0.15)
                )
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

#Preview {
    TemplateBuilderView()
        .modelContainer(for: [WorkoutTemplate.self, Exercise.self], inMemory: true)
}
