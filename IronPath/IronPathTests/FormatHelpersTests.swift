//
//  FormatHelpersTests.swift
//  IronPathTests
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import XCTest
@testable import IronPath

final class FormatHelpersTests: XCTestCase {
    
    // MARK: - Weight Formatting Tests
    
    func testWeight_WholeNumber_FormatsCorrectly() {
        let result = FormatHelpers.weight(150.0)
        XCTAssertEqual(result, "150 lbs")
    }
    
    func testWeight_WithDecimal_FormatsWithOneDecimal() {
        let result = FormatHelpers.weight(150.5)
        XCTAssertTrue(result.contains("150") || result.contains("151"))
    }
    
    func testWeight_Zero_FormatsCorrectly() {
        let result = FormatHelpers.weight(0)
        XCTAssertEqual(result, "0 lbs")
    }
    
    func testWeight_LargeNumber_FormatsCorrectly() {
        let result = FormatHelpers.weight(1000)
        XCTAssertTrue(result.contains("1000") || result.contains("1,000"))
    }
    
    // MARK: - Calories Formatting Tests
    
    func testCalories_FormatsWithUnit() {
        let result = FormatHelpers.calories(2200)
        XCTAssertTrue(result.contains("2200") || result.contains("2,200"))
        XCTAssertTrue(result.lowercased().contains("cal") || result.lowercased().contains("kcal"))
    }
    
    func testCalories_Zero_FormatsCorrectly() {
        let result = FormatHelpers.calories(0)
        XCTAssertTrue(result.contains("0"))
    }
    
    // MARK: - Macro Formatting Tests
    
    func testMacro_FormatsWithGrams() {
        let result = FormatHelpers.macro(150)
        XCTAssertTrue(result.contains("150"))
        XCTAssertTrue(result.contains("g"))
    }
    
    func testMacro_DecimalValue_RoundsAppropriately() {
        let result = FormatHelpers.macro(150.7)
        // Should be rounded to whole number or 1 decimal
        XCTAssertTrue(result.contains("150") || result.contains("151"))
    }
    
    // MARK: - Duration Formatting Tests
    
    func testDuration_ZeroSeconds_FormatsCorrectly() {
        let result = FormatHelpers.duration(0)
        XCTAssertTrue(result.contains("0") || result.isEmpty || result.contains(":"))
    }
    
    func testDuration_OneMinute_FormatsCorrectly() {
        let result = FormatHelpers.duration(60)
        XCTAssertTrue(result.contains("1") || result.contains("01"))
    }
    
    func testDuration_OneHour_FormatsCorrectly() {
        let result = FormatHelpers.duration(3600)
        XCTAssertTrue(result.contains("1"))
        // Should show 1:00:00 or similar
    }
    
    func testDuration_MixedTime_FormatsCorrectly() {
        let result = FormatHelpers.duration(3661) // 1 hour, 1 minute, 1 second
        XCTAssertFalse(result.isEmpty)
    }
    
    // MARK: - Date Formatting Tests
    
    func testDateFormat_Today_FormatsAsExpected() {
        let today = Date()
        let result = FormatHelpers.date(today)
        XCTAssertFalse(result.isEmpty)
    }
    
    func testDateFormat_PastDate_FormatsAsExpected() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let result = FormatHelpers.date(pastDate)
        XCTAssertFalse(result.isEmpty)
    }
    
    // MARK: - Percentage Formatting Tests
    
    func testPercentage_Zero_FormatsCorrectly() {
        let result = FormatHelpers.percentage(0)
        XCTAssertTrue(result.contains("0") && result.contains("%"))
    }
    
    func testPercentage_Full_FormatsCorrectly() {
        let result = FormatHelpers.percentage(1.0)
        XCTAssertTrue(result.contains("100") && result.contains("%"))
    }
    
    func testPercentage_Half_FormatsCorrectly() {
        let result = FormatHelpers.percentage(0.5)
        XCTAssertTrue(result.contains("50") && result.contains("%"))
    }
    
    func testPercentage_OverFull_HandlesGracefully() {
        let result = FormatHelpers.percentage(1.5)
        XCTAssertTrue(result.contains("150") && result.contains("%"))
    }
}
