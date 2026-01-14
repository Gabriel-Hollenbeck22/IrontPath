//
//  EmptyStateView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    @State private var iconScale: CGFloat = 0.8
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Icon composition
            ZStack {
                // Background glow
                Circle()
                    .fill(Color.ironPathPrimary.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                // Icon circle
                ZStack {
                    Circle()
                        .fill(Color.ironPathPrimary.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .stroke(Color.ironPathPrimary.opacity(0.3), lineWidth: 2)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: icon)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(Color.ironPathPrimary)
                }
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)
            
            // Text content
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
            .opacity(textOpacity)
            
            // Action button (optional)
            if let actionTitle = actionTitle, let action = action {
                Button(action: {
                    HapticManager.mediumImpact()
                    action()
                }) {
                    Label(actionTitle, systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .neonGlowButton()
                .padding(.top, Spacing.sm)
                .opacity(textOpacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animateIn()
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            textOpacity = 1.0
        }
    }
}

// MARK: - Preset Empty States

extension EmptyStateView {
    /// Empty state for workout history
    static var noWorkouts: EmptyStateView {
        EmptyStateView(
            icon: "figure.run.circle",
            title: "No Workouts Yet",
            message: "Start your fitness journey by logging your first workout."
        )
    }
    
    /// Empty state for nutrition log
    static var noFoods: EmptyStateView {
        EmptyStateView(
            icon: "fork.knife.circle",
            title: "No Foods Logged",
            message: "Track your nutrition by logging what you eat."
        )
    }
    
    /// Empty state for analytics
    static var noAnalytics: EmptyStateView {
        EmptyStateView(
            icon: "chart.line.uptrend.xyaxis",
            title: "Not Enough Data",
            message: "Keep logging workouts and nutrition to see your trends and insights."
        )
    }
    
    /// Empty state for weight tracker
    static var noWeightEntries: EmptyStateView {
        EmptyStateView(
            icon: "scalemass",
            title: "No Weight Entries",
            message: "Start tracking your weight to see your progress over time."
        )
    }
    
    /// Empty state for exercise progress
    static var noExerciseData: EmptyStateView {
        EmptyStateView(
            icon: "dumbbell",
            title: "No Exercise Data",
            message: "Log some sets to start tracking your progress on this exercise."
        )
    }
    
    /// Empty state for recipes
    static var noRecipes: EmptyStateView {
        EmptyStateView(
            icon: "book.closed",
            title: "No Recipes Yet",
            message: "Create custom recipes to quickly log your favorite meals."
        )
    }
    
    /// Empty state for templates
    static var noTemplates: EmptyStateView {
        EmptyStateView(
            icon: "doc.text",
            title: "No Templates",
            message: "Create workout templates to quickly start your favorite routines."
        )
    }
    
    /// Empty state for search results
    static var noSearchResults: EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results Found",
            message: "Try adjusting your search or add a custom item."
        )
    }
}

// MARK: - Compact Empty State (for smaller areas)

struct CompactEmptyState: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(Color.ironPathPrimary.opacity(0.5))
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
    }
}

#Preview("Standard") {
    EmptyStateView(
        icon: "figure.run.circle",
        title: "No Workouts Yet",
        message: "Start your fitness journey by logging your first workout.",
        actionTitle: "Start Workout",
        action: {}
    )
}

#Preview("No Action") {
    EmptyStateView.noAnalytics
}

#Preview("Compact") {
    CompactEmptyState(
        icon: "fork.knife",
        message: "No foods logged today"
    )
}
