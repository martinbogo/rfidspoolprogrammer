//
//  TagDetailsModel.swift
//  Spool Programmer
//
//  Enhanced tag information display
//

import Foundation

struct TagDetails {
    let uid: String
    let tagType: String
    let memoryUsed: Int
    let memoryTotal: Int
    let readDate: Date
    let hasData: Bool
    let dataType: String?
    
    var memoryUsagePercent: Double {
        guard memoryTotal > 0 else { return 0 }
        return Double(memoryUsed) / Double(memoryTotal) * 100
    }
    
    var memoryUsageText: String {
        "\(memoryUsed) / \(memoryTotal) bytes"
    }
    
    var formattedReadDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: readDate, relativeTo: Date())
    }
}
