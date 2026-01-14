//
//  UserProfileTests.swift
//  IronPathTests
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import XCTest
import SwiftData
@testable import IronPath

final class UserProfileTests: XCTestCase {
    
    // MARK: - Protein Target Calculation Tests
    
    func testCalculateProteinTarget_WithBodyWeight_ReturnsCorrectValue() {
        // Given
        let profile = UserProfile(bodyWeight: 180)
        
        // When
        let target = profile.calculateProteinTarget(multiplier: 0.9)
        
        // Then: 180 * 0.9 = 162
        XCTAssertEqual(target, 162)
    }
    
    func testCalculateProteinTarget_DefaultMultiplier_Uses0_9() {
        // Given
        let profile = UserProfile(bodyWeight: 200)
        
        // When
        let target = profile.calculateProteinTarget()
        
        // Then: 200 * 0.9 = 180
        XCTAssertEqual(target, 180)
    }
    
    func testCalculateProteinTarget_NoBodyWeight_ReturnsNil() {
        // Given
        let profile = UserProfile()
        
        // When
        let target = profile.calculateProteinTarget()
        
        // Then
        XCTAssertNil(target)
    }
    
    func testCalculateProteinTarget_CustomMultiplier_Works() {
        // Given
        let profile = UserProfile(bodyWeight: 150)
        
        // When: Using 1.0g per lb for muscle gain
        let target = profile.calculateProteinTarget(multiplier: 1.0)
        
        // Then
        XCTAssertEqual(target, 150)
    }
    
    // MARK: - BMR Calculation Tests
    
    func testCalculateBMR_Male_ReturnsCorrectValue() {
        // Given: Male, 180 lbs, 70 inches (5'10"), 30 years old
        let profile = UserProfile(
            bodyWeight: 180,
            heightInches: 70,
            age: 30,
            biologicalSex: .male,
            activityLevel: .moderate
        )
        
        // When
        let bmr = profile.calculateBMR()
        
        // Then: Using Mifflin-St Jeor equation with activity multiplier
        // BMR = (10 * 81.6kg + 6.25 * 177.8cm - 5 * 30 + 5) * 1.55
        // Base BMR ≈ 1799
        // With moderate activity (1.55) ≈ 2789
        XCTAssertNotNil(bmr)
        XCTAssertGreaterThan(bmr!, 2500)
        XCTAssertLessThan(bmr!, 3200)
    }
    
    func testCalculateBMR_Female_ReturnsCorrectValue() {
        // Given: Female, 140 lbs, 64 inches (5'4"), 28 years old
        let profile = UserProfile(
            bodyWeight: 140,
            heightInches: 64,
            age: 28,
            biologicalSex: .female,
            activityLevel: .moderate
        )
        
        // When
        let bmr = profile.calculateBMR()
        
        // Then: Female calculation uses -161 instead of +5
        XCTAssertNotNil(bmr)
        XCTAssertGreaterThan(bmr!, 1800)
        XCTAssertLessThan(bmr!, 2500)
    }
    
    func testCalculateBMR_MissingWeight_ReturnsNil() {
        // Given: Missing weight
        let profile = UserProfile(
            heightInches: 70,
            age: 30,
            biologicalSex: .male
        )
        
        // When
        let bmr = profile.calculateBMR()
        
        // Then
        XCTAssertNil(bmr)
    }
    
    func testCalculateBMR_MissingHeight_ReturnsNil() {
        // Given: Missing height
        let profile = UserProfile(
            bodyWeight: 180,
            age: 30,
            biologicalSex: .male
        )
        
        // When
        let bmr = profile.calculateBMR()
        
        // Then
        XCTAssertNil(bmr)
    }
    
    func testCalculateBMR_MissingAge_ReturnsNil() {
        // Given: Missing age
        let profile = UserProfile(
            bodyWeight: 180,
            heightInches: 70,
            biologicalSex: .male
        )
        
        // When
        let bmr = profile.calculateBMR()
        
        // Then
        XCTAssertNil(bmr)
    }
    
    func testCalculateBMR_MissingSex_ReturnsNil() {
        // Given: Missing sex
        let profile = UserProfile(
            bodyWeight: 180,
            heightInches: 70,
            age: 30
        )
        
        // When
        let bmr = profile.calculateBMR()
        
        // Then
        XCTAssertNil(bmr)
    }
    
    // MARK: - Activity Level Tests
    
    func testActivityLevel_SedentaryMultiplier() {
        XCTAssertEqual(ActivityLevel.sedentary.multiplier, 1.2)
    }
    
    func testActivityLevel_LightMultiplier() {
        XCTAssertEqual(ActivityLevel.light.multiplier, 1.375)
    }
    
    func testActivityLevel_ModerateMultiplier() {
        XCTAssertEqual(ActivityLevel.moderate.multiplier, 1.55)
    }
    
    func testActivityLevel_ActiveMultiplier() {
        XCTAssertEqual(ActivityLevel.active.multiplier, 1.725)
    }
    
    func testActivityLevel_VeryActiveMultiplier() {
        XCTAssertEqual(ActivityLevel.veryActive.multiplier, 1.9)
    }
    
    // MARK: - Default Values Tests
    
    func testDefaultValues_AreReasonable() {
        let profile = UserProfile()
        
        XCTAssertEqual(profile.targetProtein, 150.0)
        XCTAssertEqual(profile.targetCarbs, 200.0)
        XCTAssertEqual(profile.targetFat, 65.0)
        XCTAssertEqual(profile.targetCalories, 2200.0)
        XCTAssertEqual(profile.sleepGoalHours, 7.5)
        XCTAssertEqual(profile.activityLevel, .moderate)
        XCTAssertEqual(profile.primaryGoal, .muscleGain)
    }
    
    // MARK: - Fitness Goal Tests
    
    func testFitnessGoal_DisplayNames() {
        XCTAssertEqual(FitnessGoal.muscleGain.displayName, "Muscle Gain")
        XCTAssertEqual(FitnessGoal.fatLoss.displayName, "Fat Loss")
        XCTAssertEqual(FitnessGoal.maintenance.displayName, "Maintenance")
        XCTAssertEqual(FitnessGoal.athleticPerformance.displayName, "Athletic Performance")
        XCTAssertEqual(FitnessGoal.generalHealth.displayName, "General Health")
    }
}
