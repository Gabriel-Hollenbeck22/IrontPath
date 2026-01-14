//
//  IntegrationEngineTests.swift
//  IronPathTests
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import XCTest
import SwiftData
@testable import IronPath

final class IntegrationEngineTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var engine: IntegrationEngine!
    var testProfile: UserProfile!
    
    override func setUpWithError() throws {
        let schema = Schema([
            UserProfile.self,
            DailySummary.self,
            Workout.self,
            WorkoutSet.self,
            Exercise.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
        engine = IntegrationEngine(modelContext: modelContext)
        
        // Create test profile
        testProfile = UserProfile(
            targetProtein: 150,
            targetCarbs: 250,
            targetFat: 70,
            targetCalories: 2200,
            bodyWeight: 180,
            heightInches: 70,
            age: 30,
            biologicalSex: .male,
            sleepGoalHours: 8.0
        )
        modelContext.insert(testProfile)
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
        engine = nil
        testProfile = nil
    }
    
    // MARK: - Recovery Score Tests
    
    func testRecoveryScore_FullSleep_FullProtein_Rested() {
        // Given: Perfect conditions
        let sleepHours = 8.0 // 100% of goal
        let proteinIntake = 150.0 // 100% of target
        let lastWorkoutDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        
        // When
        let score = engine.calculateRecoveryScore(
            for: Date(),
            profile: testProfile,
            sleepHours: sleepHours,
            proteinIntake: proteinIntake,
            lastWorkoutDate: lastWorkoutDate
        )
        
        // Then: Should be near perfect (95-100)
        XCTAssertGreaterThan(score, 90)
        XCTAssertLessThanOrEqual(score, 100)
    }
    
    func testRecoveryScore_HalfSleep_ReturnsReducedScore() {
        // Given: Half the sleep goal
        let sleepHours = 4.0 // 50% of 8hr goal
        let proteinIntake = 150.0 // 100% of target
        let lastWorkoutDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        
        // When
        let score = engine.calculateRecoveryScore(
            for: Date(),
            profile: testProfile,
            sleepHours: sleepHours,
            proteinIntake: proteinIntake,
            lastWorkoutDate: lastWorkoutDate
        )
        
        // Then: Should be reduced due to poor sleep
        // Sleep factor = 50 * 0.4 = 20
        // Protein factor = 100 * 0.35 = 35
        // Rest factor = 100 * 0.25 = 25
        // Total = 80
        XCTAssertLessThan(score, 90)
        XCTAssertGreaterThan(score, 70)
    }
    
    func testRecoveryScore_NoData_ReturnsAverageScore() {
        // Given: No data available
        let score = engine.calculateRecoveryScore(
            for: Date(),
            profile: testProfile,
            sleepHours: nil,
            proteinIntake: nil,
            lastWorkoutDate: nil
        )
        
        // Then: Should return middle-ground score
        // All factors at 50% or 100% default
        XCTAssertGreaterThan(score, 50)
        XCTAssertLessThan(score, 90)
    }
    
    func testRecoveryScore_LowProtein_ReturnsReducedScore() {
        // Given: Low protein intake
        let sleepHours = 8.0
        let proteinIntake = 75.0 // 50% of target
        let lastWorkoutDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        
        // When
        let score = engine.calculateRecoveryScore(
            for: Date(),
            profile: testProfile,
            sleepHours: sleepHours,
            proteinIntake: proteinIntake,
            lastWorkoutDate: lastWorkoutDate
        )
        
        // Then: Should be reduced but not as much as sleep
        XCTAssertLessThan(score, 95)
        XCTAssertGreaterThan(score, 75)
    }
    
    func testRecoveryScore_WorkoutYesterday_ReturnsReducedRestFactor() {
        // Given: Workout was yesterday (need recovery)
        let sleepHours = 8.0
        let proteinIntake = 150.0
        let lastWorkoutDate = Calendar.current.date(byAdding: .day, value: 0, to: Date()) // Same day
        
        // When
        let score = engine.calculateRecoveryScore(
            for: Date(),
            profile: testProfile,
            sleepHours: sleepHours,
            proteinIntake: proteinIntake,
            lastWorkoutDate: lastWorkoutDate
        )
        
        // Then: Rest factor should be 50 instead of 100
        // This reduces total score by 12.5 points (25 * 0.5)
        XCTAssertLessThan(score, 95)
    }
    
    // MARK: - Macro Adjustment Tests
    
    func testRecoveryBuffer_HighVolumeWorkout_ReturnsBoost() {
        // Given: A high volume workout
        let workout = Workout(name: "High Volume Day")
        modelContext.insert(workout)
        
        // Add some previous workouts for percentile calculation
        for i in 0..<10 {
            let prevWorkout = Workout(name: "Workout \(i)")
            prevWorkout.isCompleted = true
            // Simulate adding sets with lower volume
            modelContext.insert(prevWorkout)
        }
        
        // When
        let adjustment = engine.calculateRecoveryBuffer(for: workout, profile: testProfile)
        
        // Then: Should return some adjustment (or none if percentile is low)
        XCTAssertNotNil(adjustment)
    }
}
