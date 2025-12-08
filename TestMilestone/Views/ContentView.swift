//
//  ContentView.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 03.12.25.
//

import SwiftUI

struct ContentView: View {
    
    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
    }
    
    @State private var path = NavigationPath()
    
    var body: some View {
        
        NavigationStack(path: $path) {
            VStack {
                
                Image("logo")
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text("TestMilestone")
                    .font(.system(size: 18))
                
                GlossyButton(title: "Bidding Page") {
                    path.append(Route.bidding)
                }
                .padding(.top, 30)
                
                GlossyButton(title: "Negotiation Page") {
                    path.append(Route.negotiation)
                }
                .padding(.top, 10)
                
            }
            .padding()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .bidding:
                    RiderBiddingView(path: $path)
                case .negotiation:
                    RiderNegotiationView(path: $path)
                case .success:
                    SuccessfulBookingView(path: $path)
                }
            }
        }
        .tint(Color.gray)
        
    }
}
