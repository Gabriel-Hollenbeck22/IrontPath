//
//  StreakWidget.swift
//  IronPathWidget
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(
            date: Date(),
            workoutStreak: 7,
            nutritionStreak: 5,
            combinedStreak: 5
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let entry = StreakEntry(
            date: Date(),
            workoutStreak: loadWorkoutStreak(),
            nutritionStreak: loadNutritionStreak(),
            combinedStreak: loadCombinedStreak()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = StreakEntry(
            date: Date(),
            workoutStreak: loadWorkoutStreak(),
            nutritionStreak: loadNutritionStreak(),
            combinedStreak: loadCombinedStreak()
        )
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    // MARK: - Data Loading from App Groups
    
    private func loadWorkoutStreak() -> Int {
        let defaults = UserDefaults(suiteName: "group.com.ironpath.shared")
        return defaults?.integer(forKey: "workoutStreak") ?? 0
    }
    
    private func loadNutritionStreak() -> Int {
        let defaults = UserDefaults(suiteName: "group.com.ironpath.shared")
        return defaults?.integer(forKey: "nutritionStreak") ?? 0
    }
    
    private func loadCombinedStreak() -> Int {
        let defaults = UserDefaults(suiteName: "group.com.ironpath.shared")
        return defaults?.integer(forKey: "combinedStreak") ?? 0
    }
}

// MARK: - Timeline Entry

struct StreakEntry: TimelineEntry {
    let date: Date
    let workoutStreak: Int
    let nutritionStreak: Int
    let combinedStreak: Int
}

// MARK: - Widget View

struct StreakWidgetEntryView: View {
    var entry: StreakProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }
    
    // MARK: - Small Widget
    
    private var smallView: some View {
        VStack(spacing: 8) {
            // Flame icon with streak count
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            Text("\(entry.workoutStreak)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("Day Streak")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color.black
        }
    }
    
    // MARK: - Medium Widget
    
    private var mediumView: some View {
        HStack(spacing: 20) {
            // Workout streak
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                }
                
                Text("\(entry.workoutStreak)")
                    .font(.title2.bold())
                
                Text("Workout")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // Nutrition streak
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "leaf.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
                
                Text("\(entry.nutritionStreak)")
                    .font(.title2.bold())
                
                Text("Nutrition")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // Combined streak
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundStyle(.cyan)
                }
                
                Text("\(entry.combinedStreak)")
                    .font(.title2.bold())
                
                Text("Combined")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

// MARK: - Widget Configuration

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Streaks")
        .description("Track your workout and nutrition streaks.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .now, workoutStreak: 7, nutritionStreak: 5, combinedStreak: 5)
}

#Preview(as: .systemMedium) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .now, workoutStreak: 12, nutritionStreak: 8, combinedStreak: 8)
}
