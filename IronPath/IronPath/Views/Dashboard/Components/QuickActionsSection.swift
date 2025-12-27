//
//  QuickActionsSection.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct QuickActionsSection: View {
    @State private var showingWorkout = false
    @State private var showingNutrition = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Quick Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: Spacing.md) {
                HapticButton(hapticStyle: .medium) {
                    showingWorkout = true
                } label: {
                    Label("Start Workout", systemImage: "dumbbell.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.ironPathPrimary)
                        .cornerRadius(12)
                }
                
                HapticButton(hapticStyle: .medium) {
                    showingNutrition = true
                } label: {
                    Label("Log Meal", systemImage: "fork.knife")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.ironPathAccent)
                        .cornerRadius(12)
                }
            }
        }
        .sheet(isPresented: $showingWorkout) {
            // TODO: Navigate to workout view
        }
        .sheet(isPresented: $showingNutrition) {
            // TODO: Navigate to nutrition search
        }
    }
}

#Preview {
    QuickActionsSection()
        .padding()
}

