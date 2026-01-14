//
//  CelebrationOverlay.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI

struct CelebrationOverlay: View {
    let title: String
    let subtitle: String
    let icon: String
    let onDismiss: () -> Void
    
    @State private var showConfetti = false
    @State private var iconScale: CGFloat = 0.3
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            // Confetti
            if showConfetti {
                ConfettiView()
            }
            
            // Content
            VStack(spacing: 32) {
                Spacer()
                
                // Animated icon
                ZStack {
                    // Glow rings
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(Color.ironPathPrimary.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                            .frame(width: CGFloat(120 + index * 30), height: CGFloat(120 + index * 30))
                            .scaleEffect(iconScale)
                    }
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.ironPathPrimary, Color.ironPathPrimary.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.ironPathPrimary.opacity(0.5), radius: 30, x: 0, y: 10)
                    
                    Image(systemName: icon)
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                
                // Text content
                VStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.title3)
                        .foregroundStyle(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .opacity(textOpacity)
                
                Spacer()
                
                // Dismiss button
                Button(action: {
                    HapticManager.lightImpact()
                    onDismiss()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color.ironPathPrimary, Color.ironPathPrimary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.ironPathPrimary.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .opacity(buttonOpacity)
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            HapticManager.success()
            animateIn()
        }
    }
    
    private func animateIn() {
        // Show confetti immediately
        showConfetti = true
        
        // Icon animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        // Text animation
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            textOpacity = 1.0
        }
        
        // Button animation
        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            buttonOpacity = 1.0
        }
    }
}

// MARK: - Celebration Types

enum CelebrationType {
    case workoutComplete
    case streakMilestone(days: Int)
    case goalAchieved
    case personalRecord
    
    var title: String {
        switch self {
        case .workoutComplete:
            return "Workout Complete!"
        case .streakMilestone(let days):
            return "\(days) Day Streak!"
        case .goalAchieved:
            return "Goal Achieved!"
        case .personalRecord:
            return "New PR!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .workoutComplete:
            return "Great job crushing your workout today!"
        case .streakMilestone(let days):
            return "You've been consistent for \(days) days straight!"
        case .goalAchieved:
            return "You hit your target. Keep it up!"
        case .personalRecord:
            return "You've set a new personal record!"
        }
    }
    
    var icon: String {
        switch self {
        case .workoutComplete:
            return "checkmark.circle.fill"
        case .streakMilestone:
            return "flame.fill"
        case .goalAchieved:
            return "star.fill"
        case .personalRecord:
            return "trophy.fill"
        }
    }
}

// MARK: - View Extension for Easy Use

extension View {
    func celebrationOverlay(
        isPresented: Binding<Bool>,
        type: CelebrationType
    ) -> some View {
        self.overlay {
            if isPresented.wrappedValue {
                CelebrationOverlay(
                    title: type.title,
                    subtitle: type.subtitle,
                    icon: type.icon,
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isPresented.wrappedValue = false
                        }
                    }
                )
                .transition(.opacity)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CelebrationOverlay(
        title: "Workout Complete!",
        subtitle: "Great job crushing your workout today!",
        icon: "checkmark.circle.fill",
        onDismiss: {}
    )
}
