//
//  Bid.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 07.12.25.
//

import Foundation

struct Bid: Codable, Identifiable, Equatable {
    var id: String { driverId + timestamp }
    let driverId: String
    let bidAmount: Double
    var timestamp: String
    var isWinner: Bool = false
    var isOutbid: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case driverId
        case bidAmount
        case timestamp
    }
    
    init(driverId: String, bidAmount: Double, timestamp: String, isWinner: Bool = false, isOutbid: Bool = false) {
        self.driverId = driverId
        self.bidAmount = bidAmount
        self.timestamp = timestamp
        self.isWinner = isWinner
        self.isOutbid = isOutbid
    }
}
