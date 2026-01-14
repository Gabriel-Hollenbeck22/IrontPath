# IronPath Unit Tests Setup Guide

This document explains how to add the unit test target to your Xcode project.

## Step 1: Add Unit Test Target

1. In Xcode, go to **File > New > Target**
2. Select **Unit Testing Bundle**
3. Name it **IronPathTests**
4. Make sure "Host Application" is set to **IronPath**
5. Click **Finish**

## Step 2: Add Test Files

Copy these test files to the IronPathTests folder:
- `IntegrationEngineTests.swift`
- `NutritionServiceTests.swift`
- `FormatHelpersTests.swift`
- `UserProfileTests.swift`

## Step 3: Configure Test Target

Make sure the test target has access to the main app's code:

1. Select the **IronPathTests** target
2. Go to **Build Phases**
3. Verify that **IronPath.app** is listed under "Host Application"

## Step 4: Import Main Module

Each test file uses `@testable import IronPath` to access internal types.
Make sure this import compiles correctly.

## Running Tests

### Via Xcode
- Press `Cmd + U` to run all tests
- Click the diamond icon next to individual tests to run them

### Via Terminal
```bash
xcodebuild test -scheme IronPath -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Coverage

### IntegrationEngineTests
- Recovery score calculation with various inputs
- Sleep, protein, and rest factor weighting
- Macro adjustment recommendations

### UserProfileTests
- Protein target calculation
- BMR calculation (Mifflin-St Jeor equation)
- Activity level multipliers
- Default value validation

### NutritionServiceTests
- Food item creation from search results
- Daily summary creation and retrieval
- Macro calculation with various servings
- Edge cases (zero/fractional servings)

### FormatHelpersTests
- Weight formatting with units
- Calorie formatting
- Macro formatting (grams)
- Duration formatting
- Percentage formatting

## Best Practices

1. **Test naming**: Use descriptive names like `testMethodName_Condition_ExpectedResult`
2. **Arrange-Act-Assert**: Structure tests with Given/When/Then
3. **In-memory data**: Use `isStoredInMemoryOnly: true` for SwiftData tests
4. **Independence**: Each test should be independent and not rely on others
