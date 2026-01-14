//
//  WelcomeView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void
    
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var featuresOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated logo
            logoSection
            
            // App name and tagline
            titleSection
            
            // Feature highlights
            featuresSection
            
            Spacer()
            
            // Continue button
            continueButton
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 40)
        .onAppear {
            animateIn()
        }
    }
    
    // MARK: - Sections
    
    private var logoSection: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.ironPathPrimary.opacity(0.4),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 20)
            
            // Icon container
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.ironPathPrimary,
                                Color.ironPathPrimary.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.white)
            }
            .shadow(color: Color.ironPathPrimary.opacity(0.5), radius: 20, x: 0, y: 10)
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
    }
    
    private var titleSection: some View {
        VStack(spacing: 12) {
            Text("IronPath")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.white.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text("Your Intelligent Fitness Companion")
                .font(.title3)
                .foregroundStyle(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .opacity(textOpacity)
    }
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            FeatureRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Track Progress",
                description: "Monitor strength gains over time"
            )
            
            FeatureRow(
                icon: "brain.head.profile",
                title: "Smart Insights",
                description: "Science-backed recommendations"
            )
            
            FeatureRow(
                icon: "fork.knife",
                title: "Nutrition Sync",
                description: "Connect workouts and diet"
            )
        }
        .opacity(featuresOpacity)
    }
    
    private var continueButton: some View {
        Button(action: {
            HapticManager.mediumImpact()
            onContinue()
        }) {
            HStack {
                Text("Get Started")
                    .font(.headline)
                Image(systemName: "arrow.right")
            }
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
    }
    
    // MARK: - Animation
    
    private func animateIn() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            textOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
            featuresOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
            buttonOpacity = 1.0
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.ironPathPrimary.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.ironPathPrimary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WelcomeView(onContinue: {})
    }
}
