//
//  GoalsSelectionView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI

struct GoalsSelectionView: View {
    @Binding var selectedGoal: FitnessGoal
    let onContinue: () -> Void
    
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Header
            VStack(spacing: 12) {
                Text("What's Your Goal?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("We'll customize your experience based on this")
                    .font(.body)
                    .foregroundStyle(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            // Goal options
            VStack(spacing: 12) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    GoalOptionCard(
                        goal: goal,
                        isSelected: selectedGoal == goal,
                        onSelect: {
                            HapticManager.selection()
                            withAnimation(.spring(response: 0.3)) {
                                selectedGoal = goal
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 8)
            
            Spacer()
            
            // Continue button
            Button(action: {
                HapticManager.mediumImpact()
                onContinue()
            }) {
                HStack {
                    Text("Continue")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color.ironPathPrimary, Color.ironPathPrimary.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color.ironPathPrimary.opacity(0.4), radius: 15, x: 0, y: 8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .opacity(contentOpacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                contentOpacity = 1.0
            }
        }
    }
}

// MARK: - Goal Option Card

struct GoalOptionCard: View {
    let goal: FitnessGoal
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.ironPathPrimary : Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconForGoal)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : Color.white.opacity(0.7))
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Text(descriptionForGoal)
                        .font(.caption)
                        .foregroundStyle(Color.white.opacity(0.6))
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.ironPathPrimary : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.ironPathPrimary)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.ironPathPrimary.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var iconForGoal: String {
        switch goal {
        case .muscleGain:
            return "figure.strengthtraining.traditional"
        case .fatLoss:
            return "flame.fill"
        case .maintenance:
            return "equal.circle.fill"
        case .athleticPerformance:
            return "figure.run"
        case .generalHealth:
            return "heart.fill"
        }
    }
    
    private var descriptionForGoal: String {
        switch goal {
        case .muscleGain:
            return "Build muscle and increase strength"
        case .fatLoss:
            return "Lose body fat while maintaining muscle"
        case .maintenance:
            return "Maintain your current physique"
        case .athleticPerformance:
            return "Optimize for sports and athletics"
        case .generalHealth:
            return "Focus on overall health and wellness"
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        GoalsSelectionView(selectedGoal: .constant(.muscleGain), onContinue: {})
    }
}
