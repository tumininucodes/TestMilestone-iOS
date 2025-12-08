//
//  SuccessfulBookingView.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 08.12.25.
//

import SwiftUI

struct SuccessfulBookingView: View {
    
    @Binding var path: NavigationPath
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Image("success-icon")
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Text("Ride booked successfully")
                .font(.system(size: 18))
            
            Spacer()
        
            GlossyButton(title: "Go Home") {
                path = NavigationPath()
            }
            .padding(.horizontal, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            
        }
    }
}
