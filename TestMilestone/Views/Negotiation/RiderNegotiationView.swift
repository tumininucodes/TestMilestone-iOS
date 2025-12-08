//
//  RiderNegotiationView.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 07.12.25.
//

import SwiftUI

struct RiderNegotiationView: View {
    
    @Binding var path: NavigationPath
    @StateObject private var viewModel = RiderNegotiationViewModel()
    @State private var proceedProgress: Double = 0.0
    @State private var hasStartedProceedAnimation: Bool = false
    
    @State private var bidInput: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        
        VStack(spacing: 10) {
            if viewModel.shouldShowRetryMessage {
                Text("Failed to connect. Trying to connect again")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            
            VStack(spacing: 20) {
                Text("Your Offer")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                
                ZStack {
                    RippleBackgroundView(rippleColor: Color.green.opacity(0.5), duration: 1.3)
                        .frame(width: 160, height: 160)
                        .opacity(viewModel.isWinnerFound ? 0.0 : 1.0)
                    
                    Text("Br250")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 118, height: 118)
                        .background(Color.white)
                        .clipShape(Circle())
                        .foregroundColor(.darkGreen)
                        .shadow(radius: 2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {

                HStack {
                    Spacer()
                    Text("Drivers' Counter Offers")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    Spacer()
                }
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.bidList) { bid in
                            BidItemView(bid: bid)
                                .id(bid.id)
                                .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale(scale: 0.95)), removal: .opacity))
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            
            if viewModel.isWinnerFound {
                GlossyButton(title: "Proceed", progress: proceedProgress) {
                    path.append(Route.success)
                    hasStartedProceedAnimation = true
                    proceedProgress = 1.0
                }
                .padding(.horizontal, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .task {
                    guard !hasStartedProceedAnimation else { return }
                    hasStartedProceedAnimation = true
                    await autoProceedTimer()
                }
            } else {
                HStack(spacing: 12) {
                    TextField("Enter amount", text: $bidInput)
                        .focused($isInputFocused)
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.lightGreen.opacity(0.3))
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            }
                        )
                        .keyboardType(.numberPad)
                    
                    GlossyButton(title: "Send") {
                        viewModel.sendBid(amount: bidInput)
                        bidInput = ""
                        isInputFocused = false
                    }
                    .frame(width: 100)
                
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
        .onDisappear {
            viewModel.stopNegotiation()
            proceedProgress = 0.0
        }
        
    }
    
    func autoProceedTimer() async {
        proceedProgress = 0.0
        withAnimation(.linear(duration: 5.0)) {
            proceedProgress = 1.0
        }
        
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        if !Task.isCancelled {
            path.append(Route.success)
        }
    }
}
