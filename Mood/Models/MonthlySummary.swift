//
//  MonthlySummary.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import Foundation

struct MonthlySummary: Identifiable, Codable {
    var id = UUID()
    var month: Date
    var emotionAverages: [EmotionType: Double]
    var smallMessage: String
    
    init(month: Date, emotionAverages: [EmotionType: Double], smallMessage: String) {
        self.month = month
        self.emotionAverages = emotionAverages
        self.smallMessage = smallMessage
    }
    
    // Custom Codable to support dictionary with EmotionType keys
    private enum CodingKeys: String, CodingKey {
        case id
        case month
        case emotionAverages
        case smallMessage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        month = try container.decode(Date.self, forKey: .month)
        smallMessage = try container.decode(String.self, forKey: .smallMessage)
        
        // Decode [String: Double] then map keys to EmotionType
        let rawDict = try container.decode([String: Double].self, forKey: .emotionAverages)
        var mapped: [EmotionType: Double] = [:]
        for (key, value) in rawDict {
            if let emotion = EmotionType(rawValue: key) {
                mapped[emotion] = value
            }
        }
        emotionAverages = mapped
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(month, forKey: .month)
        try container.encode(smallMessage, forKey: .smallMessage)
        
        // Encode dictionary using rawValue keys
        let rawDict = Dictionary(uniqueKeysWithValues: emotionAverages.map { ($0.key.rawValue, $0.value) })
        try container.encode(rawDict, forKey: .emotionAverages)
    }
}

