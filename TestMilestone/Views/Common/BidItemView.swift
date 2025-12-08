//
//  BidItemView.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 07.12.25.
//

import SwiftUI

struct BidItemView: View {
    let bid: Bid
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
        
            Image("avatar")
                .resizable()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    Text("DriverID: #\(bid.driverId)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.primary)
                    
                    if bid.isOutbid {
                        Text("Outbid")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange))
                    }
                }
                
                Text(formatTimestamp(bid.timestamp))
                    .font(.system(size: 14))
                    .foregroundColor(Color.secondary)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Br \(String(format: "%.0f", bid.bidAmount))")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.darkGreen)
                
                Text("\(String(describing: calculateLatency(bid.timestamp)))ms")
                    .font(.system(size: 14))
                    .foregroundColor(Color.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(12)
        .background{
            if bid.isWinner {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.darkGreen, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.lightGreen))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cardBorder, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }
    
    private func formatTimestamp(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm:ss a, d MMM yyyy"
            return displayFormatter.string(from: date)
        }
        return isoString
    }
}
