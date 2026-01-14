//
//  ProfileSetupView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI

struct ProfileSetupView: View {
    @Binding var onboardingData: OnboardingData
    let onContinue: () -> Void
    
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Text("About You")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Help us calculate your personalized targets")
                        .font(.body)
                        .foregroundStyle(Color.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Input fields
                VStack(spacing: 20) {
                    // Biological Sex
                    InputSection(title: "Biological Sex") {
                        HStack(spacing: 12) {
                            ForEach([BiologicalSex.male, .female], id: \.self) { sex in
                                SexButton(
                                    sex: sex,
                                    isSelected: onboardingData.biologicalSex == sex,
                                    onSelect: {
                                        HapticManager.selection()
                                        onboardingData.biologicalSex = sex
                                    }
                                )
                            }
                        }
                    }
                    
                    // Age
                    InputSection(title: "Age") {
                        HStack {
                            Text("\(onboardingData.age)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text("years")
                                .font(.body)
                                .foregroundStyle(Color.white.opacity(0.6))
                            
                            Spacer()
                            
                            Stepper("", value: $onboardingData.age, in: 13...100)
                                .labelsHidden()
                                .tint(Color.ironPathPrimary)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Weight
                    InputSection(title: "Weight") {
                        HStack {
                            Text("\(Int(onboardingData.weight))")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text("lbs")
                                .font(.body)
                                .foregroundStyle(Color.white.opacity(0.6))
                            
                            Spacer()
                            
                            Stepper("", value: $onboardingData.weight, in: 80...400, step: 1)
                                .labelsHidden()
                                .tint(Color.ironPathPrimary)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Height
                    InputSection(title: "Height") {
                        HStack {
                            HStack(spacing: 4) {
                                Text("\(onboardingData.heightFeet)")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text("'")
                                    .font(.title)
                                    .foregroundStyle(Color.white.opacity(0.6))
                                Text("\(onboardingData.heightInchesRemainder)")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text("\"")
                                    .font(.title)
                                    .foregroundStyle(Color.white.opacity(0.6))
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 8) {
                                Stepper("Feet", value: $onboardingData.heightFeet, in: 4...7)
                                    .labelsHidden()
                                Stepper("Inches", value: $onboardingData.heightInchesRemainder, in: 0...11)
                                    .labelsHidden()
                            }
                            .tint(Color.ironPathPrimary)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Activity Level
                    InputSection(title: "Activity Level") {
                        VStack(spacing: 8) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                ActivityLevelButton(
                                    level: level,
                                    isSelected: onboardingData.activityLevel == level,
                                    onSelect: {
                                        HapticManager.selection()
                                        onboardingData.activityLevel = level
                                    }
                                )
                            }
                        }
                    }
                }
                
                // Calculated targets preview
                TargetPreviewCard(onboardingData: onboardingData)
                
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
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .opacity(contentOpacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                contentOpacity = 1.0
            }
        }
    }
}

// MARK: - Input Section

struct InputSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.white.opacity(0.7))
            
            content
        }
    }
}

// MARK: - Sex Button

struct SexButton: View {
    let sex: BiologicalSex
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Image(systemName: sex == .male ? "figure.stand" : "figure.stand.dress")
                    .font(.system(size: 32))
                    .foregroundStyle(isSelected ? Color.ironPathPrimary : Color.white.opacity(0.5))
                
                Text(sex == .male ? "Male" : "Female")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? .white : Color.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white.opacity(isSelected ? 0.1 : 0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.ironPathPrimary.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Activity Level Button

struct ActivityLevelButton: View {
    let level: ActivityLevel
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                    
                    Text(descriptionForLevel)
                        .font(.caption)
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                
                Spacer()
                
                Circle()
                    .fill(isSelected ? Color.ironPathPrimary : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.ironPathPrimary : Color.white.opacity(0.3), lineWidth: 2)
                    )
            }
            .padding(12)
            .background(Color.white.opacity(isSelected ? 0.08 : 0.03))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
    
    private var descriptionForLevel: String {
        switch level {
        case .sedentary:
            return "Desk job, little exercise"
        case .light:
            return "Light exercise 1-3 days/week"
        case .moderate:
            return "Moderate exercise 3-5 days/week"
        case .active:
            return "Hard exercise 6-7 days/week"
        case .veryActive:
            return "Very hard exercise, physical job"
        }
    }
}

// MARK: - Target Preview Card

struct TargetPreviewCard: View {
    let onboardingData: OnboardingData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Calculated Targets")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ironPathPrimary)
            
            HStack(spacing: 16) {
                TargetItem(
                    label: "Calories",
                    value: "\(Int(onboardingData.calculatedCalorieTarget))",
                    unit: "kcal"
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                TargetItem(
                    label: "Protein",
                    value: "\(Int(onboardingData.calculatedProteinTarget))",
                    unit: "g"
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                TargetItem(
                    label: "Carbs",
                    value: "\(Int(onboardingData.calculatedCarbTarget))",
                    unit: "g"
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                TargetItem(
                    label: "Fat",
                    value: "\(Int(onboardingData.calculatedFatTarget))",
                    unit: "g"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ironPathPrimary.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.ironPathPrimary.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct TargetItem: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(unit)
                .font(.caption2)
                .foregroundStyle(Color.white.opacity(0.5))
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.white.opacity(0.6))
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ProfileSetupView(onboardingData: .constant(OnboardingData()), onContinue: {})
    }
}
