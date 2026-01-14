//
//  NutritionServiceTests.swift
//  IronPathTests
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import XCTest
import SwiftData
@testable import IronPath

final class NutritionServiceTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var nutritionService: NutritionService!
    
    override func setUpWithError() throws {
        let schema = Schema([
            FoodItem.self,
            LoggedFood.self,
            DailySummary.self,
            UserProfile.self,
            Recipe.self,
            RecipeIngredient.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
        nutritionService = NutritionService(modelContext: modelContext)
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
        nutritionService = nil
    }
    
    // MARK: - Food Item Creation Tests
    
    func testCreateFoodItem_FromSearchItem_CreatesCorrectly() {
        // Given
        let searchItem = FoodSearchItem(
            name: "Chicken Breast",
            brand: "Generic",
            calories: 165,
            protein: 31,
            carbs: 0,
            fat: 3.6,
            servingSizeGrams: 100,
            barcode: "123456789"
        )
        
        // When
        let foodItem = nutritionService.createFoodItem(from: searchItem)
        
        // Then
        XCTAssertEqual(foodItem.name, "Chicken Breast")
        XCTAssertEqual(foodItem.brand, "Generic")
        XCTAssertEqual(foodItem.caloriesPerServing, 165)
        XCTAssertEqual(foodItem.proteinPerServing, 31)
        XCTAssertEqual(foodItem.carbsPerServing, 0)
        XCTAssertEqual(foodItem.fatPerServing, 3.6)
        XCTAssertEqual(foodItem.servingSizeGrams, 100)
        XCTAssertEqual(foodItem.barcode, "123456789")
    }
    
    // MARK: - Daily Summary Tests
    
    func testGetTodaysSummary_CreatesNewIfNotExists() async throws {
        // When
        let summary = try nutritionService.getTodaysSummary()
        
        // Then
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary.totalCalories, 0)
        XCTAssertEqual(summary.totalProtein, 0)
    }
    
    func testGetTodaysSummary_ReturnsSameForSameDay() async throws {
        // Given
        let firstSummary = try nutritionService.getTodaysSummary()
        
        // When
        let secondSummary = try nutritionService.getTodaysSummary()
        
        // Then
        XCTAssertEqual(firstSummary.id, secondSummary.id)
    }
    
    // MARK: - Macro Calculation Tests
    
    func testLogFood_UpdatesDailySummary() throws {
        // Given
        let summary = try nutritionService.getTodaysSummary()
        let initialCalories = summary.totalCalories
        
        let foodItem = FoodItem(
            name: "Test Food",
            caloriesPerServing: 200,
            proteinPerServing: 25,
            carbsPerServing: 10,
            fatPerServing: 8
        )
        modelContext.insert(foodItem)
        
        // When
        nutritionService.logFood(foodItem, to: summary, servings: 1.0)
        
        // Then
        XCTAssertEqual(summary.totalCalories, initialCalories + 200)
    }
    
    func testLogFood_MultipleServings_CalculatesCorrectly() throws {
        // Given
        let summary = try nutritionService.getTodaysSummary()
        
        let foodItem = FoodItem(
            name: "Rice",
            caloriesPerServing: 130,
            proteinPerServing: 2.7,
            carbsPerServing: 28,
            fatPerServing: 0.3
        )
        modelContext.insert(foodItem)
        
        // When: Log 2 servings
        nutritionService.logFood(foodItem, to: summary, servings: 2.0)
        
        // Then
        XCTAssertEqual(summary.totalCalories, 260) // 130 * 2
        XCTAssertEqual(summary.totalProtein, 5.4) // 2.7 * 2
        XCTAssertEqual(summary.totalCarbs, 56) // 28 * 2
    }
    
    // MARK: - Food Search Item Tests
    
    func testFoodSearchItem_Initialization() {
        let item = FoodSearchItem(
            name: "Apple",
            brand: nil,
            calories: 95,
            protein: 0.5,
            carbs: 25,
            fat: 0.3,
            servingSizeGrams: 182,
            barcode: nil
        )
        
        XCTAssertEqual(item.name, "Apple")
        XCTAssertNil(item.brand)
        XCTAssertEqual(item.calories, 95)
        XCTAssertNil(item.barcode)
    }
    
    // MARK: - Edge Cases
    
    func testLogFood_ZeroServings_DoesNotAddCalories() throws {
        // Given
        let summary = try nutritionService.getTodaysSummary()
        let initialCalories = summary.totalCalories
        
        let foodItem = FoodItem(
            name: "Test",
            caloriesPerServing: 500,
            proteinPerServing: 50,
            carbsPerServing: 50,
            fatPerServing: 20
        )
        modelContext.insert(foodItem)
        
        // When
        nutritionService.logFood(foodItem, to: summary, servings: 0.0)
        
        // Then
        XCTAssertEqual(summary.totalCalories, initialCalories)
    }
    
    func testLogFood_FractionalServings_CalculatesCorrectly() throws {
        // Given
        let summary = try nutritionService.getTodaysSummary()
        
        let foodItem = FoodItem(
            name: "Oats",
            caloriesPerServing: 150,
            proteinPerServing: 5,
            carbsPerServing: 27,
            fatPerServing: 3
        )
        modelContext.insert(foodItem)
        
        // When: Log 0.5 servings
        nutritionService.logFood(foodItem, to: summary, servings: 0.5)
        
        // Then
        XCTAssertEqual(summary.totalCalories, 75) // 150 * 0.5
        XCTAssertEqual(summary.totalProtein, 2.5) // 5 * 0.5
    }
}
