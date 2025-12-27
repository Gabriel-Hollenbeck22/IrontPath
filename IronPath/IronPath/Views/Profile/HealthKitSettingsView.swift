//
//  HealthKitSettingsView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct HealthKitSettingsView: View {
    @State private var healthKitManager = HealthKitManager()
    @State private var isAuthorized = false
    @State private var isRequesting = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(isAuthorized ? "Authorized" : "Not Authorized")
                            .foregroundStyle(isAuthorized ? .green : .orange)
                    }
                    
                    if !isAuthorized {
                        Button(action: requestAuthorization) {
                            Label("Request Authorization", systemImage: "heart.fill")
                        }
                        .disabled(isRequesting)
                    }
                } header: {
                    Text("HealthKit")
                } footer: {
                    Text("IronPath needs access to read your sleep, weight, and activity data to provide personalized recovery recommendations.")
                }
                
                if isAuthorized {
                    Section {
                        Button(action: syncData) {
                            Label("Sync Today's Data", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
            .navigationTitle("HealthKit")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isAuthorized = healthKitManager.isAuthorized
            }
        }
    }
    
    private func requestAuthorization() {
        isRequesting = true
        
        Task {
            do {
                try await healthKitManager.requestAuthorization()
                await MainActor.run {
                    isAuthorized = true
                    isRequesting = false
                    HapticManager.success()
                }
            } catch {
                print("HealthKit authorization error: \(error)")
                await MainActor.run {
                    isRequesting = false
                    HapticManager.error()
                }
            }
        }
    }
    
    private func syncData() {
        Task {
            do {
                try await healthKitManager.syncTodaysData()
                await MainActor.run {
                    HapticManager.success()
                }
            } catch {
                print("Sync error: \(error)")
                await MainActor.run {
                    HapticManager.error()
                }
            }
        }
    }
}

#Preview {
    HealthKitSettingsView()
}

