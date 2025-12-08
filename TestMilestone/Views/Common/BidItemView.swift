//
//  BidItemView.swift
//  TestMilestone
//
//  Created by Antigravity on 07.12.25.
//

import SwiftUI

struct BidItemView: View {
    let bid: Bid
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Avatar
            Image(systemName: "person.circle.fill") // Placeholder as 'avatar' asset is missing
                .resizable()
                .frame(width: 45, height: 45)
                .foregroundColor(.gray)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    Text("Driver ID: #\(bid.driverId)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13)) // #212121
                    
                    if bid.isOutbid {
                        Text("Outbid")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 2)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange))
                    }
                }
                
                // Timestamp
                // Note: Formatting string timestamp "2025-..." to "10:30 AM..." requires Date parsing.
                // For now displaying raw or simpler format if parsing fails.
                Text(formatTimestamp(bid.timestamp))
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46)) // #757575
                    .padding(.top, 4)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Br \(String(format: "%.2f", bid.bidAmount))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.30, green: 0.69, blue: 0.31)) // #4CAF50
                
                Text("50ms") // Static as per request/XML, or calculate if data available
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46)) // #757575
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.88, green: 0.88, blue: 0.88), lineWidth: 1) // #E0E0E0
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
        )
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }
    
    private func formatTimestamp(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a, d'th' MMM yyyy" // Approximation of "10:30 AM, 13th Dec 2025"
            // Note: "th" suffix logic is complex for DateFormatter, sticking to simple pattern for MVP
            displayFormatter.dateFormat = "h:mm a, d MMM yyyy" 
            return displayFormatter.string(from: date)
        }
        return isoString
    }
}
