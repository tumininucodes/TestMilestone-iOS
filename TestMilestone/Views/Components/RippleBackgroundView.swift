//
//  RippleBackgroundView.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 07.12.25.
//

import SwiftUI

struct RippleBackgroundView: View {
    var rippleColor: Color = .green
    var duration: Double = 4.0
    
    @State private var isAnimating = true
    
    var body: some View {
        GeometryReader { geometry in
            RippleCircle(
                color: rippleColor,
                duration: duration,
                isAnimating: isAnimating
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct RippleCircle: View {
    var color: Color
    var duration: Double
    var isAnimating: Bool
    
    @State private var scale: CGFloat = 0.66
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Circle()
            .fill(color)
            .scaleEffect(scale)
            .opacity(opacity)
            .task {
                if isAnimating {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        withAnimation(
                            .linear(duration: duration)
                            .repeatForever(autoreverses: false)
                        ) {
                            scale = 1.0
                            opacity = 0.0
                        }
                    }
                }
            }
    }
}
