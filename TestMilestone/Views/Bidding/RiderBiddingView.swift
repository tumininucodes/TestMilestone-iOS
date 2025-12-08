//
//  RiderBiddingView.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 07.12.25.
//

import SwiftUI


struct RiderBiddingView: View {
    
    @Binding var path: NavigationPath
    @StateObject private var viewModel = RiderBiddingViewModel()
    @State private var scrollTarget: String?
    @State private var proceedProgress: Double = 0.0
    @State private var hasStartedProceedAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 5) {
            if viewModel.shouldShowRetryMessage {
                Text("Failed to connect. Trying to connect again")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.red)
                    .cornerRadius(8)
                    .padding(.top, 10)
            }
            
            Text("Bid Time")
                .font(.body)
                .foregroundColor(.gray)
            
            ZStack(alignment: .center) {
                
                RippleBackgroundView(rippleColor: viewModel.progressColor.opacity(0.5), duration: 1.3)
                    .frame(width: 200, height: 200)
                    .opacity(viewModel.isBiddingActive ? 1.0 : 0.0)
                
                CircularProgressView(progress: Double(viewModel.progress) / 10000.0, color: viewModel.progressColor)
                    .frame(width: 130, height: 130)
                
                Text(viewModel.timeLeft)
                    .font(.system(size: 30, weight: .bold))
                    .frame(width: 118, height: 118)
                    .background(Color.white)
                    .clipShape(Circle())
                    .foregroundColor(.black)
                    .animation(nil)
                
            }
            .frame(width: 200, height: 200)
            .padding(.vertical, 0)
            
            GlossyButton(title: viewModel.isBiddingActive ? "Leave Bid" : "Join Bid") {
                if viewModel.isBiddingActive {
                    viewModel.stopTimer()
                } else {
                    DispatchQueue.main.async {
                        viewModel.startTimer(onError: { error in
                            print("Error: \(error)")
                        }, onFinish: { winner in
                            hasStartedProceedAnimation = false
                            print("Winner: \(winner)")
                            scrollTarget = winner.id
                        })
                    }
                }
            }
            .padding(.horizontal, 20)
            
            HStack {
                Text("RECENT BIDS")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            if viewModel.bidList.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    Image("bids")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("No bids yet")
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.bidList) { bid in
                                BidItemView(bid: bid)
                                    .id(bid.id)
                                    .transition(
                                        .asymmetric(
                                            insertion: AnyTransition
                                                .opacity
                                                .combined(with: .scale(scale: 0.95)),
                                            removal: .opacity
                                        )
                                    )
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .onChange(of: scrollTarget) { targetId in
                        if let targetId = targetId {
                            withAnimation {
                                proxy.scrollTo(targetId, anchor: .center)
                            }
                        }
                    }
                }
            }
            
            if viewModel.timeLeft == "0s" {
                GlossyButton(title: "Proceed", progress: proceedProgress) {
                    proceedProgress = 1.0
                    hasStartedProceedAnimation = true
                    path.append(Route.success)
                }
                .padding(.horizontal, 20)
                .disabled(viewModel.isBiddingActive || viewModel.bidList.isEmpty)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .task {
                    guard !hasStartedProceedAnimation else { return }
                    hasStartedProceedAnimation = true
                    await autoProceedTimer()
                }
                .onDisappear {
                    proceedProgress = 0.0
                }
            }
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
