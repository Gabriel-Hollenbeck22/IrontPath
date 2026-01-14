//
//  OnboardingContainerView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var onboardingData = OnboardingData()
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.05, green: 0.1, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    WelcomeView(onContinue: nextPage)
                        .tag(0)
                    
                    GoalsSelectionView(
                        selectedGoal: $onboardingData.fitnessGoal,
                        onContinue: nextPage
                    )
                    .tag(1)
                    
                    ProfileSetupView(
                        onboardingData: $onboardingData,
                        onContinue: nextPage
                    )
                    .tag(2)
                    
                    PermissionsView(
                        onComplete: completeOnboarding
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                // Page indicator
                PageIndicator(currentPage: currentPage, totalPages: 4)
                    .padding(.bottom, 20)
            }
        }
    }
    
    private func nextPage() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentPage += 1
        }
    }
    
    private func completeOnboarding() {
        // Create user profile with onboarding data
        let profile = UserProfile(
            targetProtein: onboardingData.calculatedProteinTarget,
            targetCarbs: onboardingData.calculatedCarbTarget,
            targetFat: onboardingData.calculatedFatTarget,
            targetCalories: onboardingData.calculatedCalorieTarget,
            bodyWeight: onboardingData.weight,
            heightInches: onboardingData.heightInches,
            age: onboardingData.age,
            biologicalSex: onboardingData.biologicalSex,
            activityLevel: onboardingData.activityLevel,
            primaryGoal: onboardingData.fitnessGoal
        )
        profile.hasCompletedOnboarding = true
        
        modelContext.insert(profile)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save profile: \(error)")
        }
        
        HapticManager.success()
        onComplete()
    }
}

// MARK: - Page Indicator

struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.ironPathPrimary : Color.white.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }
}

// MARK: - Onboarding Data Model

struct OnboardingData {
    var fitnessGoal: FitnessGoal = .muscleGain
    var activityLevel: ActivityLevel = .moderate
    var biologicalSex: BiologicalSex = .male
    var age: Int = 25
    var weight: Double = 170 // lbs
    var heightFeet: Int = 5
    var heightInchesRemainder: Int = 10
    
    var heightInches: Double {
        Double(heightFeet * 12 + heightInchesRemainder)
    }
    
    // Calculate targets based on inputs
    var calculatedCalorieTarget: Double {
        let bmr = calculateBMR()
        let tdee = bmr * activityLevel.multiplier
        
        switch fitnessGoal {
        case .muscleGain:
            return tdee + 300 // Surplus
        case .fatLoss:
            return tdee - 500 // Deficit
        case .maintenance, .generalHealth:
            return tdee
        case .athleticPerformance:
            return tdee + 200
        }
    }
    
    var calculatedProteinTarget: Double {
        switch fitnessGoal {
        case .muscleGain, .athleticPerformance:
            return weight * 1.0 // 1g per lb
        case .fatLoss:
            return weight * 1.2 // Higher protein in deficit
        case .maintenance, .generalHealth:
            return weight * 0.8
        }
    }
    
    var calculatedCarbTarget: Double {
        let remainingCalories = calculatedCalorieTarget - (calculatedProteinTarget * 4) - (calculatedFatTarget * 9)
        return max(remainingCalories / 4, 100) // At least 100g carbs
    }
    
    var calculatedFatTarget: Double {
        return weight * 0.35 // ~0.35g per lb
    }
    
    private func calculateBMR() -> Double {
        let weightKg = weight * 0.453592
        let heightCm = heightInches * 2.54
        
        if biologicalSex == .male {
            return 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
        } else {
            return 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
        }
    }
}

#Preview {
    OnboardingContainerView(onComplete: {})
        .modelContainer(for: UserProfile.self, inMemory: true)
}
