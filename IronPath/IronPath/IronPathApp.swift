//
//  IronPathApp.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/26/25.
//

import SwiftUI
import SwiftData

// #region debug log helper
func debugLog(_ location: String, _ message: String, _ data: [String: Any] = [:], hypothesisId: String = "") {
    let logPath = "/Users/gabehollenbeck/Desktop/IronPath Ai/.cursor/debug.log"
    let timestamp = Int(Date().timeIntervalSince1970 * 1000)
    var logData: [String: Any] = ["location": location, "message": message, "data": data, "timestamp": timestamp, "sessionId": "debug-session"]
    if !hypothesisId.isEmpty { logData["hypothesisId"] = hypothesisId }
    if let jsonData = try? JSONSerialization.data(withJSONObject: logData), let jsonString = String(data: jsonData, encoding: .utf8) {
        if let handle = FileHandle(forWritingAtPath: logPath) {
            handle.seekToEndOfFile()
            handle.write((jsonString + "\n").data(using: .utf8)!)
            handle.closeFile()
        } else {
            FileManager.default.createFile(atPath: logPath, contents: (jsonString + "\n").data(using: .utf8))
        }
    }
}
// #endregion

@main
struct IronPathApp: App {
    @State private var showOnboarding = false
    @State private var hasCheckedOnboarding = false
    
    var sharedModelContainer: ModelContainer = {
        // #region agent log
        debugLog("IronPathApp.swift:container-init", "Starting ModelContainer initialization", [:], hypothesisId: "C")
        // #endregion
        let schema = Schema([
            // Core Models
            UserProfile.self,
            DailySummary.self,
            WeightEntry.self,
            StreakData.self,
            
            // Workout Models
            Exercise.self,
            Workout.self,
            WorkoutSet.self,
            WorkoutTemplate.self,
            TemplateExercise.self,
            
            // Nutrition Models
            FoodItem.self,
            LoggedFood.self,
            Recipe.self,
            RecipeIngredient.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            // #region agent log
            debugLog("IronPathApp.swift:container-success", "ModelContainer created successfully", [:], hypothesisId: "C")
            // #endregion
            return container
        } catch {
            // #region agent log
            debugLog("IronPathApp.swift:container-error", "ModelContainer FAILED", ["error": "\(error)"], hypothesisId: "C")
            // #endregion
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCheckedOnboarding {
                    if showOnboarding {
                        OnboardingContainerView {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showOnboarding = false
                            }
                        }
                        .transition(.opacity)
                    } else {
                        ContentView()
                            .transition(.opacity)
                    }
                } else {
                    // Loading state
                    ZStack {
                        Color.black.ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
            }
            .onAppear {
                // #region agent log
                debugLog("IronPathApp.swift:onAppear", "View appeared, starting setup", [:], hypothesisId: "B")
                // #endregion
                let context = sharedModelContainer.mainContext
                
                // #region agent log
                debugLog("IronPathApp.swift:loading-exercises", "Loading exercise library", [:], hypothesisId: "B")
                // #endregion
                // Load exercise library first
                ExerciseLibraryLoader.importExercisesIfNeeded(modelContext: context)
                
                // #region agent log
                debugLog("IronPathApp.swift:loading-templates", "Loading workout templates", [:], hypothesisId: "B")
                // #endregion
                // Then load workout templates (depends on exercises)
                TemplateLoader.importTemplatesIfNeeded(modelContext: context)
                TemplateLoader.linkExercises(modelContext: context)
                
                // #region agent log
                debugLog("IronPathApp.swift:checking-onboarding", "Checking onboarding status", [:], hypothesisId: "B")
                // #endregion
                // Check if onboarding is needed
                checkOnboardingStatus(context: context)
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func checkOnboardingStatus(context: ModelContext) {
        // #region agent log
        debugLog("IronPathApp.swift:checkOnboarding-start", "Starting onboarding check", [:], hypothesisId: "A,B,D")
        // #endregion
        let descriptor = FetchDescriptor<UserProfile>()
        
        do {
            let profiles = try context.fetch(descriptor)
            // #region agent log
            debugLog("IronPathApp.swift:checkOnboarding-fetched", "Fetched profiles", ["count": profiles.count, "hasCompleted": (profiles.first?.hasCompletedOnboarding ?? false) as Any], hypothesisId: "A,B")
            // #endregion
            // Treat nil as false (user hasn't completed onboarding)
            let needsOnboarding = profiles.isEmpty || (profiles.first?.hasCompletedOnboarding ?? false) == false
            
            // #region agent log
            debugLog("IronPathApp.swift:checkOnboarding-setting-state", "Setting state", ["needsOnboarding": needsOnboarding], hypothesisId: "B,E")
            // #endregion
            withAnimation {
                showOnboarding = needsOnboarding
                hasCheckedOnboarding = true
            }
            // #region agent log
            debugLog("IronPathApp.swift:checkOnboarding-complete", "Onboarding check complete", ["showOnboarding": needsOnboarding, "hasCheckedOnboarding": true], hypothesisId: "B,E")
            // #endregion
        } catch {
            // #region agent log
            debugLog("IronPathApp.swift:checkOnboarding-error", "Error fetching profiles", ["error": "\(error)"], hypothesisId: "A,D")
            // #endregion
            print("Error checking onboarding status: \(error)")
            withAnimation {
                showOnboarding = true
                hasCheckedOnboarding = true
            }
        }
    }
}
