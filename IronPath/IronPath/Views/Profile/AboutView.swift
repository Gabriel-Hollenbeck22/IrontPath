//
//  AboutView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // App Logo & Name
                headerSection
                
                // Description
                descriptionSection
                
                // Tech Stack
                techStackSection
                
                // Features
                featuresSection
                
                // Credits
                creditsSection
                
                // Legal
                legalSection
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.lg)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.ironPathPrimary, Color.ironPathPrimary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.ironPathPrimary.opacity(0.3), radius: 15, x: 0, y: 5)
                
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            Text("IronPath")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            
            Text("Your Intelligent Fitness Companion")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("Version \(Bundle.main.appVersion)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Description
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("About")
                .font(.headline)
            
            Text("""
IronPath is designed to be your complete fitness companion, combining intelligent workout tracking with comprehensive nutrition management.

Built with science-backed algorithms, IronPath helps you make smarter decisions about your training and diet by analyzing correlations between your workouts, nutrition, sleep, and recovery.
""")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Tech Stack
    
    private var techStackSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Built With")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.md) {
                TechBadge(name: "Swift", icon: "swift", color: .orange)
                TechBadge(name: "SwiftUI", icon: "rectangle.stack.fill", color: .blue)
                TechBadge(name: "SwiftData", icon: "cylinder.fill", color: .purple)
                TechBadge(name: "HealthKit", icon: "heart.fill", color: .red)
                TechBadge(name: "WidgetKit", icon: "rectangle.3.group.fill", color: .cyan)
                TechBadge(name: "Charts", icon: "chart.xyaxis.line", color: .green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Features
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Key Features")
                .font(.headline)
            
            VStack(spacing: Spacing.sm) {
                FeatureItem(
                    icon: "figure.strengthtraining.traditional",
                    title: "Smart Workout Tracking",
                    description: "Progressive overload suggestions and muscle group recovery"
                )
                
                FeatureItem(
                    icon: "fork.knife",
                    title: "Nutrition Logging",
                    description: "Barcode scanning and macro tracking"
                )
                
                FeatureItem(
                    icon: "brain.head.profile",
                    title: "Intelligent Insights",
                    description: "Science-backed recommendations based on your data"
                )
                
                FeatureItem(
                    icon: "flame.fill",
                    title: "Streak Tracking",
                    description: "Stay motivated with streak milestones"
                )
                
                FeatureItem(
                    icon: "heart.fill",
                    title: "HealthKit Integration",
                    description: "Sync with Apple Health for comprehensive tracking"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Credits
    
    private var creditsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Credits")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Developed by Gabriel Hollenbeck")
                    .font(.subheadline)
                
                Text("Icons by SF Symbols")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("Nutrition data powered by Open Food Facts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Legal
    
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Legal")
                .font(.headline)
            
            VStack(spacing: 1) {
                Link(destination: URL(string: "https://ironpath.app/privacy")!) {
                    HStack {
                        Text("Privacy Policy")
                            .font(.body)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(Spacing.cardPadding)
                }
                .buttonStyle(.plain)
                
                Divider()
                
                Link(destination: URL(string: "https://ironpath.app/terms")!) {
                    HStack {
                        Text("Terms of Service")
                            .font(.body)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(Spacing.cardPadding)
                }
                .buttonStyle(.plain)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            Text("© 2026 IronPath. All rights reserved.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.sm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Tech Badge

struct TechBadge: View {
    let name: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            
            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Feature Item

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.ironPathPrimary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
