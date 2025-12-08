//
//  HelperFunctions.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 08.12.25.
//

import Foundation

func calculateLatency(_ iso: String) -> Int64 {
    
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = .init(secondsFromGMT: 0)
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    guard let date = formatter.date(from: iso) else { return 0 }
    
    let now = getUTCISO()
    
    guard let nowDate = formatter.date(from: now) else { return 0 }
    
    let diff = abs(nowDate.timeIntervalSince(date) * 1000)
  
    return Int64(diff)
}


func getUTCISO() -> String {
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: Date())
}
