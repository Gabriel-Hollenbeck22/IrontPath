//
//  WorkoutTemplatesView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData

struct WorkoutTemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \WorkoutTemplate.name) private var allTemplates: [WorkoutTemplate]
    
    @State private var showingTemplateBuilder = false
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var showingStartConfirmation = false
    
    var onStartWorkout: ((WorkoutTemplate) -> Void)?
    
    private var builtInTemplates: [WorkoutTemplate] {
        allTemplates.filter { $0.isBuiltIn }
    }
    
    private var customTemplates: [WorkoutTemplate] {
        allTemplates.filter { !$0.isBuiltIn }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Built-in Templates
                    if !builtInTemplates.isEmpty {
                        templateSection(
                            title: "Workout Programs",
                            subtitle: "Science-backed training splits",
                            templates: builtInTemplates
                        )
                    }
                    
                    // Custom Templates
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("My Templates")
                                    .font(.cardTitle)
                                
                                Text("Your custom workout routines")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                showingTemplateBuilder = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.ironPathPrimary)
                            }
                        }
                        
                        if customTemplates.isEmpty {
                            ContentUnavailableView(
                                "No Custom Templates",
                                systemImage: "doc.badge.plus",
                                description: Text("Create your own workout routine")
                            )
                            .frame(height: 200)
                        } else {
                            ForEach(customTemplates) { template in
                                TemplateCard(
                                    template: template,
                                    onStart: { startWorkout(from: template) },
                                    onEdit: { selectedTemplate = template }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingTemplateBuilder) {
                TemplateBuilderView()
            }
            .sheet(item: $selectedTemplate) { template in
                TemplateBuilderView(existingTemplate: template)
            }
            .background(
                LinearGradient(
                    colors: [Color.subtleGradientTop, Color.subtleGradientBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    // MARK: - Template Section
    
    private func templateSection(title: String, subtitle: String, templates: [WorkoutTemplate]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.cardTitle)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(templates) { template in
                        TemplatePreviewCard(template: template) {
                            startWorkout(from: template)
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
    
    // MARK: - Start Workout
    
    private func startWorkout(from template: WorkoutTemplate) {
        // Update template usage
        template.lastUsed = Date()
        template.useCount += 1
        try? modelContext.save()
        
        HapticManager.success()
        
        if let callback = onStartWorkout {
            callback(template)
            dismiss()
        }
    }
}

// MARK: - Template Preview Card (Horizontal Scroll)

struct TemplatePreviewCard: View {
    let template: WorkoutTemplate
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            Text(template.name)
                .font(.headline)
                .lineLimit(1)
            
            if let description = template.templateDescription {
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Stats
            HStack(spacing: Spacing.md) {
                Label("\(template.exercises?.count ?? 0)", systemImage: "dumbbell.fill")
                Label("\(template.totalSets)", systemImage: "number")
                Label("~\(template.estimatedDuration)m", systemImage: "clock")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            // Muscle groups
            HStack {
                ForEach(template.muscleGroups.prefix(3), id: \.self) { group in
                    Text(group.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.ironPathPrimary.opacity(0.15))
                        .foregroundStyle(Color.ironPathPrimary)
                        .cornerRadius(8)
                }
                
                if template.muscleGroups.count > 3 {
                    Text("+\(template.muscleGroups.count - 3)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Start Button
            Button {
                onStart()
            } label: {
                Text("Start")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.ironPathPrimary)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
        }
        .padding(Spacing.md)
        .frame(width: 220, height: 220)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
    }
}

// MARK: - Template Card (Full Width)

struct TemplateCard: View {
    let template: WorkoutTemplate
    let onStart: () -> Void
    let onEdit: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(template.name)
                        .font(.headline)
                    
                    HStack(spacing: Spacing.md) {
                        Label("\(template.exercises?.count ?? 0) exercises", systemImage: "dumbbell.fill")
                        Label("~\(template.estimatedDuration) min", systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Menu {
                    Button {
                        onEdit()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        // Delete handled externally
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Exercise preview
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(isExpanded ? "Hide exercises" : "Show exercises")
                        .font(.caption)
                        .foregroundStyle(Color.ironPathPrimary)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.ironPathPrimary)
                }
            }
            
            if isExpanded {
                VStack(spacing: Spacing.xs) {
                    ForEach(template.sortedExercises) { exercise in
                        HStack {
                            Text(exercise.displayName)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(exercise.targetSets) × \(exercise.targetReps)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.vertical, Spacing.sm)
            }
            
            // Start Button
            Button {
                onStart()
            } label: {
                Label("Start Workout", systemImage: "play.fill")
            }
            .neonGlowButton()
        }
        .premiumCard()
    }
}

#Preview {
    WorkoutTemplatesView()
        .modelContainer(for: WorkoutTemplate.self, inMemory: true)
}
