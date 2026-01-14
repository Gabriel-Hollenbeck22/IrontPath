//
//  ExerciseProgressView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData
import Charts

struct ExerciseProgressView: View {
    @Environment(\.modelContext) private var modelContext
    
    let exercise: Exercise
    
    @Query private var allSets: [WorkoutSet]
    
    @State private var selectedTimeRange: TimeRange = .month
    @State private var selectedMetric: ProgressMetric = .estimatedOneRM
    
    private var exerciseSets: [WorkoutSet] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -selectedTimeRange.days, to: Date()) ?? Date()
        return allSets
            .filter { $0.exercise?.id == exercise.id && $0.timestamp >= cutoffDate }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    private var personalRecord: WorkoutSet? {
        allSets
            .filter { $0.exercise?.id == exercise.id }
            .max { $0.estimated1RM < $1.estimated1RM }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Personal Record Card
                personalRecordCard
                
                // Time Range & Metric Pickers
                pickerSection
                
                // Progress Chart
                progressChart
                
                // Statistics
                statisticsSection
                
                // Recent Sets
                recentSetsSection
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.lg)
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(
                colors: [Color.subtleGradientTop, Color.subtleGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Personal Record Card
    
    private var personalRecordCard: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("Personal Record")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let pr = personalRecord {
                        Text("\(Int(pr.estimated1RM)) lbs")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                        
                        Text("Est. 1RM")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No PR yet")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Best Set Details
                if let pr = personalRecord {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Best Set")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("\(Int(pr.weight)) × \(pr.reps)")
                            .font(.title3.bold())
                        
                        Text(pr.timestamp, format: .dateTime.month().day().year())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Muscle group badge
            HStack {
                Label(exercise.muscleGroup.rawValue.capitalized, systemImage: "figure.strengthtraining.traditional")
                    .font(.caption)
                    .foregroundStyle(Color.ironPathPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.ironPathPrimary.opacity(0.15))
                    .cornerRadius(12)
                
                Label(exercise.equipment.rawValue.capitalized, systemImage: "dumbbell.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                
                Spacer()
            }
        }
        .accentCard()
    }
    
    // MARK: - Picker Section
    
    private var pickerSection: some View {
        VStack(spacing: Spacing.sm) {
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("Metric", selection: $selectedMetric) {
                ForEach(ProgressMetric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - Progress Chart
    
    private var progressChart: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Progress Over Time")
                .font(.cardTitle)
            
            if exerciseSets.isEmpty {
                Text("No sets recorded in this period")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.xl)
            } else {
                Chart {
                    ForEach(exerciseSets) { set in
                        let yValue = metricValue(for: set)
                        
                        PointMark(
                            x: .value("Date", set.timestamp, unit: .day),
                            y: .value(selectedMetric.rawValue, yValue)
                        )
                        .foregroundStyle(Color.ironPathPrimary)
                        .symbolSize(40)
                        
                        LineMark(
                            x: .value("Date", set.timestamp, unit: .day),
                            y: .value(selectedMetric.rawValue, yValue)
                        )
                        .foregroundStyle(Color.ironPathPrimary.opacity(0.5))
                        .interpolationMethod(.catmullRom)
                    }
                    
                    // Trend line
                    if let trendData = calculateTrend() {
                        LineMark(
                            x: .value("Date", trendData.startDate, unit: .day),
                            y: .value("Trend", trendData.startValue)
                        )
                        .foregroundStyle(Color.ironPathSuccess)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        
                        LineMark(
                            x: .value("Date", trendData.endDate, unit: .day),
                            y: .value("Trend", trendData.endValue)
                        )
                        .foregroundStyle(Color.ironPathSuccess)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .frame(height: 220)
            }
        }
        .premiumCard()
    }
    
    private func metricValue(for set: WorkoutSet) -> Double {
        switch selectedMetric {
        case .estimatedOneRM:
            return set.estimated1RM
        case .weight:
            return set.weight
        case .volume:
            return set.weight * Double(set.reps)
        case .reps:
            return Double(set.reps)
        }
    }
    
    private func calculateTrend() -> (startDate: Date, startValue: Double, endDate: Date, endValue: Double)? {
        guard exerciseSets.count >= 3 else { return nil }
        
        let values = exerciseSets.map { metricValue(for: $0) }
        let firstHalf = Array(values.prefix(values.count / 2))
        let secondHalf = Array(values.suffix(values.count / 2))
        
        let firstAvg = firstHalf.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0, +) / Double(secondHalf.count)
        
        return (
            exerciseSets.first!.timestamp,
            firstAvg,
            exerciseSets.last!.timestamp,
            secondAvg
        )
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        let values = exerciseSets.map { metricValue(for: $0) }
        let average = values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        let max = values.max() ?? 0
        let totalVolume = exerciseSets.reduce(0) { $0 + $1.weight * Double($1.reps) }
        
        return HStack(spacing: Spacing.md) {
            StatCard(
                title: "Avg \(selectedMetric.shortName)",
                value: "\(Int(average))",
                subtitle: selectedMetric.unit,
                icon: "chart.bar.fill",
                color: .ironPathPrimary
            )
            
            StatCard(
                title: "Best",
                value: "\(Int(max))",
                subtitle: selectedMetric.unit,
                icon: "trophy.fill",
                color: .yellow
            )
            
            StatCard(
                title: "Total Vol",
                value: formatVolume(totalVolume),
                subtitle: "lbs",
                icon: "sum",
                color: .ironPathAccent
            )
        }
    }
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return "\(Int(volume))"
    }
    
    // MARK: - Recent Sets Section
    
    private var recentSetsSection: some View {
        let recentSets = Array(exerciseSets.suffix(10).reversed())
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recent Sets")
                .font(.cardTitle)
            
            ForEach(recentSets) { set in
                SetHistoryRow(set: set)
            }
        }
        .premiumCard()
    }
}

// MARK: - Progress Metric

enum ProgressMetric: String, CaseIterable {
    case estimatedOneRM = "Est. 1RM"
    case weight = "Weight"
    case volume = "Volume"
    case reps = "Reps"
    
    var unit: String {
        switch self {
        case .estimatedOneRM, .weight, .volume:
            return "lbs"
        case .reps:
            return "reps"
        }
    }
    
    var shortName: String {
        switch self {
        case .estimatedOneRM: return "1RM"
        case .weight: return "Weight"
        case .volume: return "Volume"
        case .reps: return "Reps"
        }
    }
}

// MARK: - Set History Row

struct SetHistoryRow: View {
    let set: WorkoutSet
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(set.timestamp, format: .dateTime.month().day())
                    .font(.subheadline)
                
                Text(set.timestamp, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Weight x Reps
            HStack(spacing: 4) {
                Text("\(Int(set.weight))")
                    .font(.headline)
                Text("×")
                    .foregroundStyle(.secondary)
                Text("\(set.reps)")
                    .font(.headline)
            }
            
            Spacer()
            
            // Estimated 1RM
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(set.estimated1RM))")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.ironPathPrimary)
                Text("1RM")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .nestedCard()
    }
}

// MARK: - Exercise Progress List View

struct ExerciseProgressListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @Query private var workoutSets: [WorkoutSet]
    
    private var exercisesWithSets: [Exercise] {
        let exerciseIdsWithSets = Set(workoutSets.compactMap { $0.exercise?.id })
        return exercises.filter { exerciseIdsWithSets.contains($0.id) }
    }
    
    var body: some View {
        List {
            if exercisesWithSets.isEmpty {
                ContentUnavailableView(
                    "No Exercise History",
                    systemImage: "dumbbell.fill",
                    description: Text("Complete some workouts to track progress")
                )
            } else {
                ForEach(exercisesWithSets) { exercise in
                    NavigationLink {
                        ExerciseProgressView(exercise: exercise)
                    } label: {
                        ExerciseProgressRow(exercise: exercise, sets: workoutSets.filter { $0.exercise?.id == exercise.id })
                    }
                }
            }
        }
        .navigationTitle("Exercise Progress")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Exercise Progress Row

struct ExerciseProgressRow: View {
    let exercise: Exercise
    let sets: [WorkoutSet]
    
    private var personalRecord: Double {
        sets.map { $0.estimated1RM }.max() ?? 0
    }
    
    private var lastSession: Date? {
        sets.map { $0.timestamp }.max()
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                
                HStack(spacing: Spacing.sm) {
                    Label(exercise.muscleGroup.rawValue.capitalized, systemImage: "figure.strengthtraining.traditional")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let last = lastSession {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(last, format: .relative(presentation: .named))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(personalRecord))")
                    .font(.title3.bold())
                    .foregroundStyle(Color.ironPathPrimary)
                Text("PR 1RM")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseProgressView(
            exercise: Exercise(name: "Bench Press", muscleGroup: .chest, equipment: .barbell)
        )
    }
    .modelContainer(for: [Exercise.self, WorkoutSet.self], inMemory: true)
}
