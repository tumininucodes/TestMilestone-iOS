//
//  CircularProgressView.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 07.12.25.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var lineWidth: CGFloat = 12
    var color: Color? = nil
    
    private var defaultProgressColor: Color {
        switch progress {
        case 0.7...1.0:
            return .green
        case 0.4..<0.7:
            return .yellow
        case 0.2..<0.4:
            return .orange
        case 0.0..<0.2:
            return .red
        default:
            return .green
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(red: 0.85, green: 0.95, blue: 0.95), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(color ?? defaultProgressColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}

