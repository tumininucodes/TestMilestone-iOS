//
//  RiderBiddingViewModel.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 07.12.25.
//

import SwiftUI
import Combine

class RiderBiddingViewModel: ObservableObject {
    
    @Published var progress: Int = 0
    @Published var timeLeft: String = "10s"
    @Published var progressColor: Color = Color.green
    @Published var bidList: [Bid] = []
    @Published var isBiddingActive: Bool = false
    @Published var shouldShowRetryMessage: Bool = false
    
    private let webSocketService = WebSocketService()
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    private let totalTime: Int = 10000
    private let interval: Double = 0.1
    var millisUntilFinished: Int = 10000
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        webSocketService.bids
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newBid in
                self?.handleNewBid(newBid)
            }
            .store(in: &cancellables)
        
        webSocketService.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                print("--------- ", state)
                self?.shouldShowRetryMessage = (state == .retrying)
            }
            .store(in: &cancellables)
    }
    
    private func handleNewBid(_ newBid: Bid) {
        var currentList = bidList
        currentList.insert(newBid, at: 0)
        
        let minAmount = currentList.map { $0.bidAmount }.min() ?? Double.greatestFiniteMagnitude
        
        let potentialWinners = currentList.filter {
            $0.bidAmount == minAmount
        }
        
        let winner = potentialWinners.last
        
        let updatedList = currentList.map { bid -> Bid in
            var mutableBid = bid
            let isWinner = bid == winner
            let isOutbid = !isWinner
            mutableBid.isWinner = isWinner
            mutableBid.isOutbid = isOutbid
            return mutableBid
        }
        
        withAnimation(.easeOut(duration: 0.3)) {
            bidList = updatedList
        }
    }
    
    func startTimer(onError: @escaping (Error) -> Void, onFinish: @escaping (Bid) -> Void) {
        bidList = []
        millisUntilFinished = totalTime
        isBiddingActive = true
        
        webSocketService.connect { error in
            print("ViewModel: WebSocket error: \(String(describing: error))")
            DispatchQueue.main.async {
                if let error = error {
                    print("ViewModel reporting error: \(error)")
                    onError(error)
                }
            }
        }
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.millisUntilFinished -= Int(self.interval * 1000)
            
            if self.millisUntilFinished <= 0 {
                self.handleTimerFinish(onFinish: onFinish)
            } else {
                self.updateProgressState(millisUntilFinished: self.millisUntilFinished)
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        webSocketService.disconnect()
        isBiddingActive = false
    }
    
    private func handleTimerFinish(onFinish: @escaping (Bid) -> Void) {
        timer?.invalidate()
        timer = nil
        
        progress = 0
        timeLeft = "0s"
        progressColor = Color.red
        isBiddingActive = false
        webSocketService.disconnect()
        
        if let winner = bidList.first(where: { $0.isWinner }) {
            onFinish(winner)
        }
    }
    
    private func updateProgressState(millisUntilFinished: Int) {
        progress = millisUntilFinished
        let secondsLeft = (millisUntilFinished + 999) / 1000
        timeLeft = "\(secondsLeft)s"
        progressColor = calculateColor(progress: millisUntilFinished)
    }
    
    private func calculateColor(progress: Int) -> Color {
        let greenR = 76.0, greenG = 175.0, greenB = 80.0
        let yellowR = 255.0, yellowG = 235.0, yellowB = 59.0
        let orangeR = 255.0, orangeG = 152.0, orangeB = 0.0
        let redR = 244.0, redG = 67.0, redB = 54.0
        
        if progress > 6666 {
            let ratio = Double(10000 - progress) / 3334.0
            let r = greenR + (yellowR - greenR) * ratio
            let g = greenG + (yellowG - greenG) * ratio
            let b = greenB + (yellowB - greenB) * ratio
            return Color(red: r/255, green: g/255, blue: b/255)
        } else if progress > 3333 {
            let ratio = Double(6666 - progress) / 3333.0
            let r = yellowR + (orangeR - yellowR) * ratio
            let g = yellowG + (orangeG - yellowG) * ratio
            let b = yellowB + (orangeB - yellowB) * ratio
            return Color(red: r/255, green: g/255, blue: b/255)
        } else {
            let ratio = Double(3333 - progress) / 3333.0
            let r = orangeR + (redR - orangeR) * ratio
            let g = orangeG + (redG - orangeG) * ratio
            let b = orangeB + (redB - orangeB) * ratio
            return Color(red: r/255, green: g/255, blue: b/255)
        }
    }
 
    
    deinit {
        stopTimer()
    }
    
    
}
