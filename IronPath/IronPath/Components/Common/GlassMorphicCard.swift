//
//  GlassMorphicCard.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct GlassMorphicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Spacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
}

#Preview {
    GlassMorphicCard {
        Text("Glassmorphic Card")
            .font(.headline)
    }
    .padding()
}

