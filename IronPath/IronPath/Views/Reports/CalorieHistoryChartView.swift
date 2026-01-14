//
//  CalorieHistoryChartView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData
import Charts

struct CalorieHistoryChartView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \DailySummary.date, order: .reverse) private var allSummaries: [DailySummary]
    @Query private var profiles: [UserProfile]
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedDate: Date?
    
    private var profile: UserProfile? { profiles.first }
    
    private var filteredSummaries: [DailySummary] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -selectedTimeRange.days, to: Date()) ?? Date()
        return allSummaries.filter { $0.date >= cutoffDate }.reversed()
    }
    
    private var statistics: CalorieStatistics {
        CalorieStatistics(summaries: Array(filteredSummaries))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Time Range Picker
                timeRangePicker
                
                // Main Chart
                calorieChart
                
                // Statistics Cards
                statisticsSection
                
                // Daily Breakdown
                dailyBreakdownSection
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.lg)
        }
        .navigationTitle("Calorie History")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(
                colors: [Color.subtleGradientTop, Color.subtleGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Time Range Picker
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - Calorie Chart
    
    private var calorieChart: some View {
        let target = profile?.targetCalories ?? 2000
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Calorie Intake")
                .font(.cardTitle)
            
            if filteredSummaries.isEmpty {
                Text("No data for this period")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.xl)
            } else {
                Chart {
                    // Target line
                    RuleMark(y: .value("Target", target))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .foregroundStyle(Color.ironPathPrimary.opacity(0.5))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Target")
                                .font(.caption2)
                                .foregroundStyle(Color.ironPathPrimary)
                        }
                    
                    // Calorie bars/area
                    ForEach(filteredSummaries) { summary in
                        AreaMark(
                            x: .value("Date", summary.date, unit: .day),
                            y: .value("Calories", summary.totalCalories)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.ironPathPrimary.opacity(0.3), Color.ironPathPrimary.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        LineMark(
                            x: .value("Date", summary.date, unit: .day),
                            y: .value("Calories", summary.totalCalories)
                        )
                        .foregroundStyle(Color.ironPathPrimary)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", summary.date, unit: .day),
                            y: .value("Calories", summary.totalCalories)
                        )
                        .foregroundStyle(summary.totalCalories >= target ? Color.ironPathSuccess : Color.orange)
                        .symbolSize(selectedDate == summary.date ? 100 : 30)
                    }
                }
                .chartYScale(domain: 0...(statistics.maxCalories * 1.2))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: xAxisStride)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let x = value.location.x
                                        if let date: Date = proxy.value(atX: x) {
                                            selectedDate = Calendar.current.startOfDay(for: date)
                                        }
                                    }
                                    .onEnded { _ in
                                        selectedDate = nil
                                    }
                            )
                    }
                }
                .frame(height: 250)
                
                // Selected date info
                if let selected = selectedDate,
                   let summary = filteredSummaries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selected) }) {
                    HStack {
                        Text(summary.date, format: .dateTime.weekday(.wide).month().day())
                            .font(.caption.bold())
                        
                        Spacer()
                        
                        Text("\(Int(summary.totalCalories)) cal")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.ironPathPrimary)
                    }
                    .padding(Spacing.sm)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .premiumCard()
    }
    
    private var xAxisStride: Int {
        switch selectedTimeRange {
        case .week: return 1
        case .twoWeeks: return 2
        case .month: return 5
        }
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        HStack(spacing: Spacing.md) {
            StatCard(
                title: "Average",
                value: "\(Int(statistics.averageCalories))",
                subtitle: "cal/day",
                icon: "chart.bar.fill",
                color: Color.ironPathPrimary
            )
            
            StatCard(
                title: "Highest",
                value: "\(Int(statistics.maxCalories))",
                subtitle: "cal",
                icon: "arrow.up.circle.fill",
                color: .orange
            )
            
            StatCard(
                title: "Lowest",
                value: "\(Int(statistics.minCalories))",
                subtitle: "cal",
                icon: "arrow.down.circle.fill",
                color: Color.ironPathSuccess
            )
        }
    }
    
    // MARK: - Daily Breakdown Section
    
    private var dailyBreakdownSection: some View {
        let target = profile?.targetCalories ?? 2000
        let daysOnTarget = filteredSummaries.filter { $0.totalCalories >= target * 0.9 && $0.totalCalories <= target * 1.1 }.count
        let daysOver = filteredSummaries.filter { $0.totalCalories > target * 1.1 }.count
        let daysUnder = filteredSummaries.filter { $0.totalCalories < target * 0.9 }.count
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Adherence Summary")
                .font(.cardTitle)
            
            HStack(spacing: Spacing.md) {
                AdherenceItem(
                    count: daysOnTarget,
                    label: "On Target",
                    color: Color.ironPathSuccess
                )
                
                AdherenceItem(
                    count: daysOver,
                    label: "Over",
                    color: .orange
                )
                
                AdherenceItem(
                    count: daysUnder,
                    label: "Under",
                    color: Color.ironPathError
                )
            }
            
            // Trend indicator
            if let trend = statistics.trend {
                HStack {
                    Image(systemName: trend > 0 ? "arrow.up.right" : "arrow.down.right")
                        .foregroundStyle(trend > 0 ? Color.orange : Color.ironPathSuccess)
                    
                    Text(trend > 0 ? "Trending up" : "Trending down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(abs(Int(trend))) cal/day")
                        .font(.caption.bold())
                }
                .padding(.top, Spacing.sm)
            }
        }
        .premiumCard()
    }
}

// MARK: - Calorie Statistics

struct CalorieStatistics {
    let summaries: [DailySummary]
    
    var averageCalories: Double {
        guard !summaries.isEmpty else { return 0 }
        return summaries.reduce(0) { $0 + $1.totalCalories } / Double(summaries.count)
    }
    
    var maxCalories: Double {
        summaries.map { $0.totalCalories }.max() ?? 0
    }
    
    var minCalories: Double {
        summaries.map { $0.totalCalories }.min() ?? 0
    }
    
    var totalCalories: Double {
        summaries.reduce(0) { $0 + $1.totalCalories }
    }
    
    /// Calculate trend (cal/day change)
    var trend: Double? {
        guard summaries.count >= 7 else { return nil }
        
        let firstHalf = Array(summaries.prefix(summaries.count / 2))
        let secondHalf = Array(summaries.suffix(summaries.count / 2))
        
        let firstAvg = firstHalf.reduce(0) { $0 + $1.totalCalories } / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0) { $0 + $1.totalCalories } / Double(secondHalf.count)
        
        return secondAvg - firstAvg
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.headline)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .nestedCard()
    }
}

struct AdherenceItem: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2.bold())
                .foregroundStyle(color)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("days")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        CalorieHistoryChartView()
    }
    .modelContainer(for: DailySummary.self, inMemory: true)
}
