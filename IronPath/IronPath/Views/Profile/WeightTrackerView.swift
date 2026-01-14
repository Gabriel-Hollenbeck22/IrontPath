//
//  WeightTrackerView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData
import Charts

struct WeightTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \WeightEntry.date, order: .reverse) private var weightEntries: [WeightEntry]
    @Query private var profiles: [UserProfile]
    
    @State private var showingAddWeight = false
    @State private var selectedTimeRange: TimeRange = .month
    @State private var healthKitManager = HealthKitManager()
    @State private var showingHealthKitImport = false
    @State private var isImporting = false
    
    private var profile: UserProfile? { profiles.first }
    
    private var filteredEntries: [WeightEntry] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -selectedTimeRange.days, to: Date()) ?? Date()
        return weightEntries.filter { $0.date >= cutoffDate }.reversed()
    }
    
    private var trend: WeightTrend {
        WeightTrend(entries: Array(filteredEntries))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Current Weight Card
                currentWeightCard
                
                // Time Range Picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                
                // Weight Chart
                weightChart
                
                // Statistics
                statisticsSection
                
                // Recent Entries
                recentEntriesSection
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.lg)
        }
        .navigationTitle("Weight Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if HealthKitManager.isHealthKitAvailable {
                    Menu {
                        Button {
                            importFromHealthKit()
                        } label: {
                            Label("Import Latest", systemImage: "arrow.down.circle")
                        }
                        
                        NavigationLink {
                            HealthKitSettingsView()
                        } label: {
                            Label("Health Settings", systemImage: "gear")
                        }
                    } label: {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddWeight = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.ironPathPrimary)
                }
            }
        }
        .sheet(isPresented: $showingAddWeight) {
            AddWeightEntryView(healthKitManager: healthKitManager)
        }
        .background(
            LinearGradient(
                colors: [Color.subtleGradientTop, Color.subtleGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Current Weight Card
    
    private var currentWeightCard: some View {
        let latestWeight = weightEntries.first?.weight
        let goalWeight = profile?.goalWeight
        let trendDirection = trend.trendDirection
        
        return VStack(spacing: Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Weight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let weight = latestWeight {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", weight))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                            
                            Text(profile?.preferredWeightUnit.displayName ?? "lbs")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("--")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Trend indicator
                if latestWeight != nil {
                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: trendDirection.icon)
                            .font(.title)
                            .foregroundStyle(trendColor)
                        
                        Text(trendDirection.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if let change = trend.weeklyChange {
                            Text("\(change >= 0 ? "+" : "")\(String(format: "%.1f", change)) /wk")
                                .font(.caption.bold())
                                .foregroundStyle(trendColor)
                        }
                    }
                }
            }
            
            // Goal Progress
            if let goal = goalWeight, let current = latestWeight {
                Divider()
                
                GoalProgressView(current: current, goal: goal, unit: profile?.preferredWeightUnit.displayName ?? "lbs")
            }
        }
        .accentCard()
    }
    
    private var trendColor: Color {
        guard let goal = profile?.goalWeight, let current = weightEntries.first?.weight else {
            return .secondary
        }
        
        let direction = trend.trendDirection
        let needsToLose = current > goal
        
        switch direction {
        case .decreasing:
            return needsToLose ? .ironPathSuccess : .orange
        case .increasing:
            return needsToLose ? .orange : .ironPathSuccess
        case .stable:
            return .secondary
        }
    }
    
    // MARK: - Weight Chart
    
    private var weightChart: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Weight History")
                .font(.cardTitle)
            
            if filteredEntries.isEmpty {
                Text("No entries for this period")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.xl)
            } else {
                Chart {
                    // Goal line (if set)
                    if let goal = profile?.goalWeight {
                        RuleMark(y: .value("Goal", goal))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .foregroundStyle(Color.ironPathSuccess.opacity(0.5))
                            .annotation(position: .top, alignment: .trailing) {
                                Text("Goal")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ironPathSuccess)
                            }
                    }
                    
                    // Weight area and line
                    ForEach(filteredEntries) { entry in
                        AreaMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.ironPathPrimary.opacity(0.3), .ironPathPrimary.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        LineMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(Color.ironPathPrimary)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(Color.ironPathPrimary)
                        .symbolSize(30)
                    }
                }
                .chartYScale(domain: yAxisDomain)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: xAxisStride)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
                .frame(height: 220)
            }
        }
        .premiumCard()
    }
    
    private var yAxisDomain: ClosedRange<Double> {
        let weights = filteredEntries.map { $0.weight }
        let minWeight = (weights.min() ?? 150) - 5
        let maxWeight = (weights.max() ?? 200) + 5
        
        // Include goal in range if set
        if let goal = profile?.goalWeight {
            return min(minWeight, goal - 5)...max(maxWeight, goal + 5)
        }
        
        return minWeight...maxWeight
    }
    
    private var xAxisStride: Int {
        switch selectedTimeRange {
        case .week: return 1
        case .twoWeeks: return 2
        case .month: return 5
        }
    }
    
    // MARK: - HealthKit Import
    
    private func importFromHealthKit() {
        isImporting = true
        
        Task {
            do {
                // Request authorization if needed
                if !healthKitManager.isAuthorized {
                    try await healthKitManager.requestAuthorization()
                }
                
                // Fetch latest weight
                if let weight = try await healthKitManager.fetchBodyWeight() {
                    await MainActor.run {
                        // Check if we already have an entry for today
                        let today = Calendar.current.startOfDay(for: Date())
                        let existingToday = weightEntries.first { entry in
                            Calendar.current.isDate(entry.date, inSameDayAs: today)
                        }
                        
                        if existingToday == nil {
                            // Create new entry
                            let entry = WeightEntry(
                                date: Date(),
                                weight: weight,
                                notes: "Imported from Apple Health"
                            )
                            modelContext.insert(entry)
                            
                            // Update profile
                            if let profile = profile {
                                profile.bodyWeight = weight
                                profile.lastUpdated = Date()
                            }
                            
                            try? modelContext.save()
                            HapticManager.success()
                        } else {
                            // Weight already logged today
                            HapticManager.lightImpact()
                        }
                        
                        isImporting = false
                    }
                } else {
                    await MainActor.run {
                        isImporting = false
                        HapticManager.error()
                    }
                }
            } catch {
                print("HealthKit import error: \(error)")
                await MainActor.run {
                    isImporting = false
                    HapticManager.error()
                }
            }
        }
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        let weights = filteredEntries.map { $0.weight }
        let average = weights.isEmpty ? 0 : weights.reduce(0, +) / Double(weights.count)
        let min = weights.min() ?? 0
        let max = weights.max() ?? 0
        
        return HStack(spacing: Spacing.md) {
            StatCard(
                title: "Average",
                value: String(format: "%.1f", average),
                subtitle: profile?.preferredWeightUnit.displayName ?? "lbs",
                icon: "chart.bar.fill",
                color: .ironPathPrimary
            )
            
            StatCard(
                title: "Highest",
                value: String(format: "%.1f", max),
                subtitle: profile?.preferredWeightUnit.displayName ?? "lbs",
                icon: "arrow.up.circle.fill",
                color: .orange
            )
            
            StatCard(
                title: "Lowest",
                value: String(format: "%.1f", min),
                subtitle: profile?.preferredWeightUnit.displayName ?? "lbs",
                icon: "arrow.down.circle.fill",
                color: .ironPathSuccess
            )
        }
    }
    
    // MARK: - Recent Entries Section
    
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recent Entries")
                .font(.cardTitle)
            
            if weightEntries.isEmpty {
                Text("No weight entries yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(weightEntries.prefix(5)) { entry in
                    WeightEntryRow(entry: entry, unit: profile?.preferredWeightUnit.displayName ?? "lbs")
                }
            }
        }
        .premiumCard()
    }
}

// MARK: - Goal Progress View

struct GoalProgressView: View {
    let current: Double
    let goal: Double
    let unit: String
    
    private var progress: Double {
        // Calculate progress as distance traveled toward goal
        // Assuming starting weight is 10% away from goal in opposite direction
        let startingWeight = goal > current ? goal * 1.1 : goal * 0.9
        let totalDistance = abs(startingWeight - goal)
        let distanceTraveled = abs(startingWeight - current)
        return min(distanceTraveled / totalDistance, 1.0)
    }
    
    private var remaining: Double {
        abs(current - goal)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Goal: \(String(format: "%.1f", goal)) \(unit)")
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(String(format: "%.1f", remaining)) \(unit) to go")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.ironPathPrimary, .ironPathSuccess],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 10)
        }
    }
}

// MARK: - Weight Entry Row

struct WeightEntryRow: View {
    let entry: WeightEntry
    let unit: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date, format: .dateTime.weekday(.abbreviated).month().day())
                    .font(.subheadline)
                
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(String(format: "%.1f", entry.weight)) \(unit)")
                    .font(.headline)
                
                if let bf = entry.bodyFatPercentage {
                    Text("\(String(format: "%.1f", bf))% BF")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .nestedCard()
    }
}

// MARK: - Add Weight Entry View

struct AddWeightEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var profiles: [UserProfile]
    
    var healthKitManager: HealthKitManager?
    
    @State private var weight: Double = 0
    @State private var bodyFatPercentage: String = ""
    @State private var notes: String = ""
    @State private var date = Date()
    @State private var syncToHealthKit = true
    
    private var profile: UserProfile? { profiles.first }
    private var canSyncToHealthKit: Bool {
        HealthKitManager.isHealthKitAvailable && (healthKitManager?.isAuthorized ?? false)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Weight") {
                    HStack {
                        TextField("Weight", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                        
                        Text(profile?.preferredWeightUnit.displayName ?? "lbs")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Optional") {
                    HStack {
                        TextField("Body Fat %", text: $bodyFatPercentage)
                            .keyboardType(.decimalPad)
                        
                        Text("%")
                            .foregroundStyle(.secondary)
                    }
                    
                    TextField("Notes", text: $notes)
                }
                
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                if canSyncToHealthKit {
                    Section {
                        Toggle(isOn: $syncToHealthKit) {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Sync to Apple Health")
                                    Text("Save this weight to HealthKit")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Log Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(weight <= 0)
                }
            }
            .onAppear {
                // Default to last known weight
                if let lastWeight = try? modelContext.fetch(
                    FetchDescriptor<WeightEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
                ).first?.weight {
                    weight = lastWeight
                } else if let profileWeight = profile?.bodyWeight {
                    weight = profileWeight
                }
            }
        }
    }
    
    private func saveEntry() {
        let entry = WeightEntry(
            date: date,
            weight: weight,
            bodyFatPercentage: Double(bodyFatPercentage),
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(entry)
        
        // Update profile's current weight
        if let profile = profile {
            profile.bodyWeight = weight
            profile.lastUpdated = Date()
        }
        
        try? modelContext.save()
        
        // Sync to HealthKit if enabled
        if syncToHealthKit && canSyncToHealthKit {
            Task {
                try? await healthKitManager?.saveBodyWeight(weight, date: date)
            }
        }
        
        HapticManager.success()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        WeightTrackerView()
    }
    .modelContainer(for: [WeightEntry.self, UserProfile.self], inMemory: true)
}
