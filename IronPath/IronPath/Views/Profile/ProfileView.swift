//
//  ProfileView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI
import SwiftData
import StoreKit

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) var requestReview
    @Query private var userProfiles: [UserProfile]
    @State private var showingEditProfile = false
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    if let profile = userProfiles.first {
                        profileInfoSection(profile: profile)
                        macroTargetsSection(profile: profile)
                        settingsSection
                    } else {
                        ContentUnavailableView(
                            "No Profile",
                            systemImage: "person.fill",
                            description: Text("Create a profile to get started")
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditProfile = true
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                if let profile = userProfiles.first {
                    EditProfileView(profile: profile)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private func profileInfoSection(profile: UserProfile) -> some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.ironPathPrimary)
            
            if let weight = profile.bodyWeight {
                Text(FormatHelpers.weight(weight))
                    .font(.title3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private func macroTargetsSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Macro Targets")
                .font(.headline)
            
            VStack(spacing: Spacing.sm) {
                HStack {
                    Text("Protein")
                    Spacer()
                    Text(FormatHelpers.macro(profile.targetProtein))
                }
                
                HStack {
                    Text("Carbs")
                    Spacer()
                    Text(FormatHelpers.macro(profile.targetCarbs))
                }
                
                HStack {
                    Text("Fat")
                    Spacer()
                    Text(FormatHelpers.macro(profile.targetFat))
                }
                
                HStack {
                    Text("Calories")
                    Spacer()
                    Text(FormatHelpers.calories(profile.targetCalories))
                }
            }
            .padding(Spacing.cardPadding)
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Settings")
                .font(.headline)
            
            VStack(spacing: 1) {
                NavigationLink(destination: WeightTrackerView()) {
                    SettingsRow(icon: "scalemass.fill", title: "Weight Tracker", color: .teal)
                }
                
                NavigationLink(destination: HealthKitSettingsView()) {
                    SettingsRow(icon: "heart.fill", title: "Apple Health", color: .red)
                }
                
                NavigationLink(destination: NotificationSettingsView()) {
                    SettingsRow(icon: "bell.fill", title: "Notifications", color: .orange)
                }
                
                NavigationLink(destination: ExportDataView()) {
                    SettingsRow(icon: "square.and.arrow.up.fill", title: "Export Data", color: .blue)
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
            
            // Support section
            Text("Support")
                .font(.headline)
                .padding(.top, Spacing.sm)
            
            VStack(spacing: 1) {
                Button {
                    HapticManager.lightImpact()
                    requestReview()
                } label: {
                    SettingsRow(icon: "star.fill", title: "Rate IronPath", color: .yellow)
                }
                .buttonStyle(.plain)
                
                Button {
                    HapticManager.lightImpact()
                    showingShareSheet = true
                } label: {
                    SettingsRow(icon: "square.and.arrow.up", title: "Share with Friends", color: .green)
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: AboutView()) {
                    SettingsRow(icon: "info.circle.fill", title: "About IronPath", color: .gray)
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
            
            // Version info
            appVersionInfo
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [
                "Check out IronPath - the intelligent fitness companion app! 💪",
                URL(string: "https://apps.apple.com/app/ironpath")!
            ])
        }
    }
    
    private var appVersionInfo: some View {
        HStack {
            Spacer()
            VStack(spacing: 2) {
                Text("IronPath")
                    .font(.caption.bold())
                Text("Version \(Bundle.main.appVersion) (\(Bundle.main.buildNumber))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.top, Spacing.md)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(width: 28, height: 28)
                
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(Spacing.cardPadding)
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}

