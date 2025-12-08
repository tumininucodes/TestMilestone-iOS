//
//  RiderNegotiationViewModel.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 08.12.25.
//

import Combine
import SwiftUI

class RiderNegotiationViewModel: ObservableObject {
    
    @Published var bidList: [Bid] = []
    @Published var isWinnerFound: Bool = false
    @Published var shouldShowRetryMessage: Bool = false
    
    private let webSocketService = WebSocketService()
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            self.startNegotiation()
        }
    }
    
    private func setupBindings() {
        webSocketService.bids
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newBid in
                print("got here")
                self?.handleNewBid(newBid)
            }
            .store(in: &cancellables)
            
        webSocketService.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.shouldShowRetryMessage = (state == .retrying)
            }
            .store(in: &cancellables)
    }
    
    func startNegotiation() {
        webSocketService.connect { error in
            print("ViewModel: WebSocket error: \(String(describing: error))")
            DispatchQueue.main.async {
                if let error = error {
                    print("Error connecting to websocket: \(error)")
                }
            }
        }
        setupBindings()
    }
    
    private func handleNewBid(_ newBid: Bid) {
        var currentList = bidList
        var modifiedBid = newBid
        
        if newBid.bidAmount <= 250 {
            modifiedBid.isWinner = true
            
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.3)) {
                    self.isWinnerFound = true
                }
                self.stopNegotiation()
            }
        }
        
        currentList.insert(modifiedBid, at: 0)
        
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.3)) {
                self.bidList = currentList
            }
        }
    }
    
    
    func stopNegotiation() {
        webSocketService.disconnect()
    }
    
    func sendBid(amount: String) {
        guard let bidAmount = Int(amount) else { return }
        
        let now = ISO8601DateFormatter().string(from: Date())
        let bid = Bid(driverId: "driver_me", bidAmount: Double(bidAmount), timestamp: now, isWinner: false, isOutbid: false)
        
        if let data = try? JSONEncoder().encode(bid),
           let jsonString = String(data: data, encoding: .utf8) {
            webSocketService.sendMessage(jsonString)
        }
    }

    func proceed() {
        print("Proceeding from Negotiation...")
    }
    
    
    
}
