//
//  DailyEmotionRecord.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import Foundation
import SwiftUI

struct DailyEmotionRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var emotionPercentages: [EmotionType: Double] = {
        var dict = [EmotionType: Double]()
        for emotion in EmotionType.allCases {
            dict[emotion] = 0
        }
        return dict
    }()
    var notes: String = ""
    var isPrivate: Bool = true
    
    var isEmpty: Bool {
        !emotionPercentages.values.contains(where: { $0 > 0 })
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

