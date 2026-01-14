//
//  TodayProgressWidget.swift
//  IronPathWidget
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct TodayProgressProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayProgressEntry {
        TodayProgressEntry(
            date: Date(),
            calories: 1500,
            calorieTarget: 2200,
            protein: 100,
            proteinTarget: 150,
            carbs: 180,
            carbTarget: 250,
            fat: 50,
            fatTarget: 70
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TodayProgressEntry) -> Void) {
        let entry = loadTodayProgress()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayProgressEntry>) -> Void) {
        let entry = loadTodayProgress()
        
        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    // MARK: - Data Loading
    
    private func loadTodayProgress() -> TodayProgressEntry {
        let defaults = UserDefaults(suiteName: "group.com.ironpath.shared")
        
        return TodayProgressEntry(
            date: Date(),
            calories: defaults?.double(forKey: "todayCalories") ?? 0,
            calorieTarget: defaults?.double(forKey: "calorieTarget") ?? 2200,
            protein: defaults?.double(forKey: "todayProtein") ?? 0,
            proteinTarget: defaults?.double(forKey: "proteinTarget") ?? 150,
            carbs: defaults?.double(forKey: "todayCarbs") ?? 0,
            carbTarget: defaults?.double(forKey: "carbTarget") ?? 250,
            fat: defaults?.double(forKey: "todayFat") ?? 0,
            fatTarget: defaults?.double(forKey: "fatTarget") ?? 70
        )
    }
}

// MARK: - Timeline Entry

struct TodayProgressEntry: TimelineEntry {
    let date: Date
    let calories: Double
    let calorieTarget: Double
    let protein: Double
    let proteinTarget: Double
    let carbs: Double
    let carbTarget: Double
    let fat: Double
    let fatTarget: Double
    
    var calorieProgress: Double {
        min(calories / max(calorieTarget, 1), 1.0)
    }
    
    var proteinProgress: Double {
        min(protein / max(proteinTarget, 1), 1.0)
    }
    
    var carbProgress: Double {
        min(carbs / max(carbTarget, 1), 1.0)
    }
    
    var fatProgress: Double {
        min(fat / max(fatTarget, 1), 1.0)
    }
}

// MARK: - Widget View

struct TodayProgressEntryView: View {
    var entry: TodayProgressProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .systemLarge:
            largeView
        default:
            smallView
        }
    }
    
    // MARK: - Small Widget (Calories Only)
    
    private var smallView: some View {
        VStack(spacing: 8) {
            Text("Calories")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ZStack {
                Circle()
                    .stroke(Color.cyan.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: entry.calorieProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(Int(entry.calories))")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text("/ \(Int(entry.calorieTarget))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 90, height: 90)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color.black
        }
    }
    
    // MARK: - Medium Widget (All Macros)
    
    private var mediumView: some View {
        HStack(spacing: 16) {
            // Calories ring
            VStack(spacing: 4) {
                MacroRing(
                    progress: entry.calorieProgress,
                    color: .cyan,
                    icon: "flame.fill",
                    size: 60
                )
                
                Text("\(Int(entry.calories))")
                    .font(.headline.bold())
                
                Text("kcal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Macros bars
            VStack(spacing: 8) {
                MacroBar(
                    label: "Protein",
                    current: entry.protein,
                    target: entry.proteinTarget,
                    color: .cyan
                )
                
                MacroBar(
                    label: "Carbs",
                    current: entry.carbs,
                    target: entry.carbTarget,
                    color: .orange
                )
                
                MacroBar(
                    label: "Fat",
                    current: entry.fat,
                    target: entry.fatTarget,
                    color: .purple
                )
            }
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color.black
        }
    }
    
    // MARK: - Large Widget
    
    private var largeView: some View {
        VStack(spacing: 16) {
            Text("Today's Nutrition")
                .font(.headline)
            
            // Calories ring (larger)
            HStack(spacing: 24) {
                MacroRing(
                    progress: entry.calorieProgress,
                    color: .cyan,
                    icon: "flame.fill",
                    size: 100
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(Int(entry.calories))")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text("of \(Int(entry.calorieTarget)) kcal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("\(Int(entry.calorieTarget - entry.calories)) remaining")
                        .font(.caption)
                        .foregroundStyle(entry.calories > entry.calorieTarget ? .red : .green)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Detailed macros
            VStack(spacing: 12) {
                DetailedMacroRow(
                    icon: "circle.fill",
                    label: "Protein",
                    current: entry.protein,
                    target: entry.proteinTarget,
                    color: .cyan
                )
                
                DetailedMacroRow(
                    icon: "circle.fill",
                    label: "Carbs",
                    current: entry.carbs,
                    target: entry.carbTarget,
                    color: .orange
                )
                
                DetailedMacroRow(
                    icon: "circle.fill",
                    label: "Fat",
                    current: entry.fat,
                    target: entry.fatTarget,
                    color: .purple
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

// MARK: - Supporting Views

struct MacroRing: View {
    let progress: Double
    let color: Color
    let icon: String
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: size * 0.1)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            Image(systemName: icon)
                .font(.system(size: size * 0.25))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
    }
}

struct MacroBar: View {
    let label: String
    let current: Double
    let target: Double
    let color: Color
    
    private var progress: Double {
        min(current / max(target, 1), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(Int(current))g")
                    .font(.caption.bold())
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 4)
        }
    }
}

struct DetailedMacroRow: View {
    let icon: String
    let label: String
    let current: Double
    let target: Double
    let color: Color
    
    private var progress: Double {
        min(current / max(target, 1), 1.0)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
            
            Text("\(Int(current))/\(Int(target))g")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .trailing)
        }
    }
}

// MARK: - Widget Configuration

struct TodayProgressWidget: Widget {
    let kind: String = "TodayProgressWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayProgressProvider()) { entry in
            TodayProgressEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Progress")
        .description("Track your daily nutrition at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    TodayProgressWidget()
} timeline: {
    TodayProgressEntry(
        date: .now,
        calories: 1650,
        calorieTarget: 2200,
        protein: 120,
        proteinTarget: 150,
        carbs: 180,
        carbTarget: 250,
        fat: 55,
        fatTarget: 70
    )
}

#Preview(as: .systemMedium) {
    TodayProgressWidget()
} timeline: {
    TodayProgressEntry(
        date: .now,
        calories: 1650,
        calorieTarget: 2200,
        protein: 120,
        proteinTarget: 150,
        carbs: 180,
        carbTarget: 250,
        fat: 55,
        fatTarget: 70
    )
}

#Preview(as: .systemLarge) {
    TodayProgressWidget()
} timeline: {
    TodayProgressEntry(
        date: .now,
        calories: 1650,
        calorieTarget: 2200,
        protein: 120,
        proteinTarget: 150,
        carbs: 180,
        carbTarget: 250,
        fat: 55,
        fatTarget: 70
    )
}
