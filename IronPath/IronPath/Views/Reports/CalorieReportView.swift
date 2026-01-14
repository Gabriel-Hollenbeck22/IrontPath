//
//  CalorieReportView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData
import Charts

struct CalorieReportView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \DailySummary.date, order: .reverse) private var summaries: [DailySummary]
    @Query private var profiles: [UserProfile]
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var healthKitManager = HealthKitManager()
    @State private var activeCalories: Double?
    @State private var steps: Int?
    @State private var isLoadingHealthData = false
    
    private var profile: UserProfile? { profiles.first }
    
    // Calculate total daily energy expenditure
    private var totalBurned: Double {
        let bmr = profile?.calculateBMR() ?? 1800
        let active = activeCalories ?? 0
        return bmr + active
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Energy Budget Card
                energyBudgetCard
                
                // HealthKit Activity Card (if available)
                if HealthKitManager.isHealthKitAvailable {
                    activityCard
                }
                
                // Calorie Breakdown Card
                calorieBreakdownCard
                
                // Daily Summary
                dailyCaloriesCard
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.lg)
        }
        .navigationTitle("Calorie Report")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(
                colors: [Color.subtleGradientTop, Color.subtleGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            loadHealthKitData()
        }
    }
    
    // MARK: - Load HealthKit Data
    
    private func loadHealthKitData() {
        guard HealthKitManager.isHealthKitAvailable && healthKitManager.isAuthorized else { return }
        
        isLoadingHealthData = true
        
        Task {
            do {
                async let calories = healthKitManager.fetchActiveCalories(for: Date())
                async let stepsData = healthKitManager.fetchSteps(for: Date())
                
                let (fetchedCalories, fetchedSteps) = try await (calories, stepsData)
                
                await MainActor.run {
                    activeCalories = fetchedCalories
                    steps = fetchedSteps
                    isLoadingHealthData = false
                }
            } catch {
                await MainActor.run {
                    isLoadingHealthData = false
                }
            }
        }
    }
    
    // MARK: - Energy Budget Card
    
    private var energyBudgetCard: some View {
        let consumed = todaysSummary?.totalCalories ?? 0
        let target = profile?.targetCalories ?? 2000
        let burned = totalBurned
        let budget = burned - consumed
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Energy Budget")
                .font(.cardTitle)
            
            HStack(spacing: Spacing.lg) {
                // Calories In
                VStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.macroCarbs)
                    Text("\(Int(consumed))")
                        .font(.title2.bold())
                    Text("Consumed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // Equals
                VStack(spacing: 4) {
                    Image(systemName: budget >= 0 ? "equal.circle.fill" : "exclamationmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(budget >= 0 ? Color.ironPathPrimary : Color.ironPathError)
                    Text("\(budget >= 0 ? "+" : "")\(Int(budget))")
                        .font(.title2.bold())
                        .foregroundStyle(budget >= 0 ? Color.ironPathSuccess : Color.ironPathError)
                    Text("Budget")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // Calories Out
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.macroProtein)
                    Text("\(Int(burned))")
                        .font(.title2.bold())
                    Text("Burned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                consumed <= target 
                                    ? Color.ironPathSuccess 
                                    : Color.ironPathError
                            )
                            .frame(width: min(CGFloat(consumed / target), 1.5) * geometry.size.width)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("Target: \(Int(target)) cal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int((consumed / target) * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(consumed <= target ? Color.ironPathSuccess : Color.ironPathError)
                }
            }
        }
        .accentCard()
    }
    
    // MARK: - Activity Card (HealthKit)
    
    private var activityCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Label("Today's Activity", systemImage: "heart.fill")
                    .font(.cardTitle)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if isLoadingHealthData {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if !healthKitManager.isAuthorized {
                    NavigationLink {
                        HealthKitSettingsView()
                    } label: {
                        Text("Connect")
                            .font(.caption.bold())
                            .foregroundStyle(Color.ironPathPrimary)
                    }
                }
            }
            
            if healthKitManager.isAuthorized {
                HStack(spacing: Spacing.lg) {
                    // BMR
                    VStack(spacing: 4) {
                        Image(systemName: "bed.double.fill")
                            .font(.title2)
                            .foregroundStyle(.indigo)
                        
                        Text("\(Int(profile?.calculateBMR() ?? 1800))")
                            .font(.headline)
                        
                        Text("BMR")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Active Calories
                    VStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        
                        if let active = activeCalories {
                            Text("\(Int(active))")
                                .font(.headline)
                        } else {
                            Text("--")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("Active")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Steps
                    VStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.title2)
                            .foregroundStyle(.green)
                        
                        if let stepsCount = steps {
                            Text("\(stepsCount)")
                                .font(.headline)
                        } else {
                            Text("--")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("Steps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Total TDEE
                    VStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.title2)
                            .foregroundStyle(Color.ironPathPrimary)
                        
                        Text("\(Int(totalBurned))")
                            .font(.headline)
                        
                        Text("TDEE")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Data source note
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                    
                    Text("Data from Apple Health")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.title)
                        .foregroundStyle(.red.opacity(0.5))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Connect Apple Health")
                            .font(.subheadline.bold())
                        
                        Text("Get accurate calorie burn data from your Apple Watch or iPhone")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, Spacing.sm)
            }
        }
        .premiumCard()
    }
    
    // MARK: - Calorie Breakdown Card
    
    private var calorieBreakdownCard: some View {
        let consumed = todaysSummary?.totalCalories ?? 0
        let protein = (todaysSummary?.totalProtein ?? 0) * 4  // 4 cal/g
        let carbs = (todaysSummary?.totalCarbs ?? 0) * 4      // 4 cal/g
        let fat = (todaysSummary?.totalFat ?? 0) * 9          // 9 cal/g
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Calorie Breakdown")
                .font(.cardTitle)
            
            if consumed > 0 {
                HStack(spacing: Spacing.md) {
                    // Pie Chart representation
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 20)
                        
                        // Protein arc
                        Circle()
                            .trim(from: 0, to: protein / consumed)
                            .stroke(Color.macroProtein, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        // Carbs arc
                        Circle()
                            .trim(from: protein / consumed, to: (protein + carbs) / consumed)
                            .stroke(Color.macroCarbs, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        // Fat arc
                        Circle()
                            .trim(from: (protein + carbs) / consumed, to: min((protein + carbs + fat) / consumed, 1))
                            .stroke(Color.macroFat, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text("\(Int(consumed))")
                                .font(.title2.bold())
                            Text("cal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 120, height: 120)
                    
                    // Legend
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        MacroBreakdownRow(
                            name: "Protein",
                            calories: Int(protein),
                            percentage: Int((protein / consumed) * 100),
                            color: .macroProtein
                        )
                        MacroBreakdownRow(
                            name: "Carbs",
                            calories: Int(carbs),
                            percentage: Int((carbs / consumed) * 100),
                            color: .macroCarbs
                        )
                        MacroBreakdownRow(
                            name: "Fat",
                            calories: Int(fat),
                            percentage: Int((fat / consumed) * 100),
                            color: .macroFat
                        )
                    }
                }
            } else {
                Text("No food logged today")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .premiumCard()
    }
    
    // MARK: - Daily Calories Card
    
    private var dailyCaloriesCard: some View {
        let recentSummaries = Array(summaries.prefix(7))
        let target = profile?.targetCalories ?? 2000
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Last 7 Days")
                .font(.cardTitle)
            
            if recentSummaries.isEmpty {
                Text("No data available")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(recentSummaries) { summary in
                    DailyCalorieRow(summary: summary, target: target)
                }
            }
        }
        .premiumCard()
    }
    
    // MARK: - Computed Properties
    
    private var todaysSummary: DailySummary? {
        summaries.first { Calendar.current.isDateInToday($0.date) }
    }
}

// MARK: - Supporting Views

struct MacroBreakdownRow: View {
    let name: String
    let calories: Int
    let percentage: Int
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(name)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(calories) cal")
                .font(.subheadline.bold())
            
            Text("(\(percentage)%)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct DailyCalorieRow: View {
    let summary: DailySummary
    let target: Double
    
    private var percentage: Double {
        summary.totalCalories / target
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(summary.date, format: .dateTime.weekday(.abbreviated).month().day())
                    .font(.subheadline)
                
                Text("\(Int(summary.totalCalories)) cal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Progress indicator
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(percentageColor)
                        .frame(width: min(CGFloat(percentage), 1.2) * geometry.size.width)
                }
            }
            .frame(width: 100, height: 8)
            
            Text("\(Int(percentage * 100))%")
                .font(.caption.bold())
                .foregroundStyle(percentageColor)
                .frame(width: 45, alignment: .trailing)
        }
        .nestedCard()
    }
    
    private var percentageColor: Color {
        switch percentage {
        case ..<0.75:
            return .ironPathError
        case 0.75..<1.1:
            return .ironPathSuccess
        default:
            return .orange
        }
    }
}

// MARK: - Time Range

enum TimeRange: String, CaseIterable {
    case week = "7 Days"
    case twoWeeks = "2 Weeks"
    case month = "Month"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .twoWeeks: return 14
        case .month: return 30
        }
    }
}

#Preview {
    NavigationStack {
        CalorieReportView()
    }
    .modelContainer(for: DailySummary.self, inMemory: true)
}
