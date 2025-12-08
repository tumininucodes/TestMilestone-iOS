//
//  GlossyButton.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 07.12.25.
//

import SwiftUI

struct GlossyButton: View {
    var title: String
    var progress: Double? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            LinearGradient(gradient: Gradient(colors: [
                                Color(red: 3/255, green: 240/255, blue: 8/255),
                                Color(red: 67/255, green: 136/255, blue: 6/255)
                            ]), startPoint: .top, endPoint: .bottom)
                            
                            if let progress = progress {
                                Color.black.opacity(0.1)
                                    .frame(width: geometry.size.width * CGFloat(progress))
                            }
                        }
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
