//
//  ConfettiView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false
    
    let colors: [Color] = [
        .ironPathPrimary,
        .ironPathAccent,
        .green,
        .yellow,
        .purple,
        .pink
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle, screenHeight: geometry.size.height)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func createParticles(in size: CGSize) {
        particles = (0..<80).map { _ in
            ConfettiParticle(
                id: UUID(),
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                color: colors.randomElement() ?? .ironPathPrimary,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.2),
                delay: Double.random(in: 0...0.5),
                duration: Double.random(in: 2.5...4.0),
                horizontalDrift: CGFloat.random(in: -50...50)
            )
        }
    }
}

// MARK: - Confetti Particle Model

struct ConfettiParticle: Identifiable {
    let id: UUID
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let rotation: Double
    let scale: CGFloat
    let delay: Double
    let duration: Double
    let horizontalDrift: CGFloat
}

// MARK: - Individual Confetti Piece

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    let screenHeight: CGFloat
    let shapeType: Int
    
    @State private var currentY: CGFloat = -20
    @State private var currentRotation: Double = 0
    @State private var currentX: CGFloat = 0
    @State private var opacity: Double = 1
    
    init(particle: ConfettiParticle, screenHeight: CGFloat) {
        self.particle = particle
        self.screenHeight = screenHeight
        self.shapeType = Int.random(in: 0...2)
    }
    
    var body: some View {
        Group {
            switch shapeType {
            case 0:
                Rectangle()
                    .fill(particle.color)
            case 1:
                Circle()
                    .fill(particle.color)
            default:
                RoundedRectangle(cornerRadius: 2)
                    .fill(particle.color)
            }
        }
        .frame(width: 10 * particle.scale, height: 14 * particle.scale)
        .rotationEffect(.degrees(currentRotation))
        .position(x: currentX, y: currentY)
        .opacity(opacity)
        .onAppear {
            currentX = particle.x
            animate()
        }
    }
    
    private func animate() {
        // Start animation after delay
        withAnimation(
            .easeIn(duration: particle.duration)
            .delay(particle.delay)
        ) {
            currentY = screenHeight + 50
            currentX = particle.x + particle.horizontalDrift
        }
        
        // Rotation animation
        withAnimation(
            .linear(duration: particle.duration / 2)
            .repeatForever(autoreverses: false)
            .delay(particle.delay)
        ) {
            currentRotation = particle.rotation + 720
        }
        
        // Fade out near end
        withAnimation(
            .easeIn(duration: 0.5)
            .delay(particle.delay + particle.duration - 0.5)
        ) {
            opacity = 0
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ConfettiView()
    }
}
