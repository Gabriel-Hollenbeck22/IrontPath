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
    @Query(
        filter: #Predicate<Workout> { !$0.isCompleted },
        sort: [SortDescriptor(\.startTime, order: .reverse)]
    ) private var activeWorkouts: [Workout]
    
    @Query(sort: \WorkoutTemplate.lastUsed, order: .reverse) private var templates: [WorkoutTemplate]
    
    @State private var workoutManager: WorkoutManager?
    @State private var isWorkoutActive = false
    @State private var showingTemplates = false
    @State private var showingQuickStart = false
    
    private var recentTemplates: [WorkoutTemplate] {
        Array(templates.filter { $0.lastUsed != nil }.prefix(3))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let activeWorkout = activeWorkouts.first {
                    if let manager = workoutManager {
                        WorkoutSessionView(workout: activeWorkout, manager: manager)
                    } else {
                        ContentUnavailableView(
                            "Loading...",
                            systemImage: "dumbbell.fill"
                        )
                    }
                } else {
                    workoutStartView
                }
            }
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                workoutManager = WorkoutManager(modelContext: modelContext)
                // Load active workout into manager if it exists
                if let activeWorkout = activeWorkouts.first {
                    workoutManager?.activeWorkout = activeWorkout
                    isWorkoutActive = true
                }
            }
            .sheet(isPresented: $showingTemplates) {
                WorkoutTemplatesView { template in
                    startWorkoutFromTemplate(template)
                }
            }
            .sheet(isPresented: $showingQuickStart) {
                QuickStartSheet { name in
                    startQuickWorkout(name: name)
                }
            }
        }
    }
    
    private var workoutStartView: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Hero Section
                VStack(spacing: Spacing.md) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.ironPathPrimary)
                    
                    Text("Ready to Train?")
                        .font(.sectionTitle)
                    
                    Text("Start a new workout or use a template")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Spacing.xl)
                
                // Start Options
                VStack(spacing: Spacing.md) {
                    // Quick Start
                    Button {
                        showingQuickStart = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Quick Start")
                                    .font(.headline)
                                Text("Start an empty workout")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "bolt.fill")
                                .font(.title2)
                        }
                        .padding()
                        .background(Color.ironPathPrimary)
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                    }
                    
                    // From Template
                    Button {
                        showingTemplates = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("From Template")
                                    .font(.headline)
                                Text("Use a workout program")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "doc.on.doc.fill")
                                .font(.title2)
                        }
                        .padding()
                        .background(Color.ironPathAccent)
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, Spacing.md)
                
                // Recent Templates
                if !recentTemplates.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Recent Templates")
                            .font(.cardTitle)
                            .padding(.horizontal, Spacing.md)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.md) {
                                ForEach(recentTemplates) { template in
                                    RecentTemplateCard(template: template) {
                                        startWorkoutFromTemplate(template)
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.md)
                        }
                    }
                }
                
                // History Link
                NavigationLink {
                    WorkoutHistoryView()
                } label: {
                    HStack {
                        Label("View Workout History", systemImage: "clock.fill")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, Spacing.md)
                
                Spacer(minLength: Spacing.xl)
            }
            .padding(.bottom, Spacing.lg)
        }
        .background(
            LinearGradient(
                colors: [Color.subtleGradientTop, Color.subtleGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Start Workout Methods
    
    private func startQuickWorkout(name: String) {
        guard let manager = workoutManager else { return }
        do {
            _ = try manager.startWorkout(name: name.isEmpty ? "Workout" : name)
            isWorkoutActive = true
            HapticManager.mediumImpact()
        } catch {
            print("Failed to start workout:", error)
        }
    }
    
    private func startWorkoutFromTemplate(_ template: WorkoutTemplate) {
        guard let manager = workoutManager else { return }
        
        do {
            // Create workout from template
            _ = try manager.startWorkout(name: template.name)
            
            // Pre-populate with template exercises (user still needs to log sets)
            // The exercises are available via template for reference
            
            // Update template usage stats
            template.lastUsed = Date()
            template.useCount += 1
            try? modelContext.save()
            
            isWorkoutActive = true
            HapticManager.success()
        } catch {
            print("Failed to start workout from template:", error)
        }
    }
}

// MARK: - Quick Start Sheet

struct QuickStartSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var onStart: (String) -> Void
    
    @State private var workoutName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Workout Name", text: $workoutName)
                } footer: {
                    Text("Give your workout a name, or leave blank for \"Workout\"")
                }
                
                Section {
                    Button {
                        onStart(workoutName)
                        dismiss()
                    } label: {
                        Label("Start Workout", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .neonGlowButton()
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Quick Start")
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

// MARK: - Recent Template Card

struct RecentTemplateCard: View {
    let template: WorkoutTemplate
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(template.name)
                .font(.headline)
                .lineLimit(1)
            
            HStack(spacing: Spacing.sm) {
                Label("\(template.exercises?.count ?? 0)", systemImage: "dumbbell.fill")
                Label("~\(template.estimatedDuration)m", systemImage: "clock")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            if let lastUsed = template.lastUsed {
                Text(lastUsed, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Button {
                onStart()
            } label: {
                Text("Start")
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.ironPathPrimary)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }
        }
        .padding(Spacing.md)
        .frame(width: 160)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
    }
}

#Preview {
    WorkoutView()
        .modelContainer(for: [Workout.self, WorkoutTemplate.self], inMemory: true)
}
