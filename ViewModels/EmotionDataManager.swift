//
//  EmotionDataManager.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import Foundation
import SwiftUI
import Combine

class EmotionDataManager: ObservableObject {
    static let shared = EmotionDataManager()
    
    @Published private(set) var dailyRecords: [DailyEmotionRecord] = []
    
    private let storageKey = "DailyEmotionRecords"
    
    private init() {
        loadData()
    }
    
    // MARK: - CRUD
    
    func dailyRecord(for date: Date) -> DailyEmotionRecord {
        if let record = dailyRecords.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return record
        } else {
            return DailyEmotionRecord(date: date)
        }
    }
    
    func save(record: DailyEmotionRecord) {
        if let index = dailyRecords.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: record.date) }) {
            dailyRecords[index] = record
        } else {
            dailyRecords.append(record)
        }
        saveData()
    }
    
    func delete(record: DailyEmotionRecord) {
        dailyRecords.removeAll { $0.id == record.id }
        saveData()
    }
    
    // MARK: - Persistence using UserDefaults
    
    private func saveData() {
        do {
            let encoded = try JSONEncoder().encode(dailyRecords)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Failed to encode dailyRecords: \(error)")
        }
    }
    
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([DailyEmotionRecord].self, from: data)
            dailyRecords = decoded
        } catch {
            print("Failed to decode dailyRecords: \(error)")
            dailyRecords = []
        }
    }
    
    // MARK: - Monthly Summary
    
    func monthlySummary(for month: Date) -> [EmotionType: Double] {
        let calendar = Calendar.current
        let monthRecords = dailyRecords.filter {
            calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
        var summary: [EmotionType: Double] = [:]
        for emotion in EmotionType.allCases {
            let total = monthRecords.reduce(0) { $0 + ($1.emotionPercentages[emotion] ?? 0) }
            summary[emotion] = monthRecords.isEmpty ? 0 : total / Double(monthRecords.count)
        }
        return summary
    }
    
    // MARK: - Message for month (enhanced: handles ties and tone)
    
    func smallMessage(for month: Date) -> String {
        let summary = monthlySummary(for: month)
        guard summary.values.contains(where: { $0 > 0 }) else {
            return "No mood recorded this month."
        }
        
        let maxValue = summary.values.max() ?? 0
        let epsilon = 0.0001
        let topEmotions = EmotionType.allCases.filter { (summary[$0] ?? 0) + epsilon >= maxValue && (summary[$0] ?? 0) > 0 }
        
        
        if topEmotions.count == 1, let e = topEmotions.first {
            return singleMessage(for: e)
        }
        
        return combinedMessage(for: topEmotions)
    }
    
    // MARK: - Helpers for message composition
    
    private var positiveEmotions: Set<EmotionType> { [.happy, .calm, .excited] }
    private var negativeEmotions: Set<EmotionType> { [.sad, .angry, .fear, .disgust] }
    private var neutralEmotions: Set<EmotionType> { [.surprised] }
    
    private func singleMessage(for emotion: EmotionType) -> String {
        switch emotion {
        // 正向
        case .happy:
            return "A joyful month! Keep nurturing what brings you happiness."
        case .calm:
            return "A calm and peaceful month. Great balance—keep it up."
        case .excited:
            return "An exciting month—ride the momentum and channel it well!"
        // 負向
        case .sad:
            return "Some sadness surfaced this month. Be gentle with yourself and seek support when needed."
        case .angry:
            return "Tough moments showed up. Remember to pause, breathe, and express needs kindly."
        case .fear:
            return "Anxieties were present. Ground yourself—small steps and self-compassion help."
        case .disgust:
            return "You faced unpleasant feelings. Protect your boundaries and practice self-care."
        // 中性
        case .surprised:
            return "A month full of surprises—stay curious and flexible."
        }
    }
    
    private func combinedMessage(for emotions: [EmotionType]) -> String {
        let positives = emotions.filter { positiveEmotions.contains($0) }
        let negatives = emotions.filter { negativeEmotions.contains($0) }
        let neutrals  = emotions.filter { neutralEmotions.contains($0) }
        
        
        let positivePart = positives.isEmpty ? nil : joinEmotions(positives) + " stand out—awesome! Keep the good vibes going."
        let negativePart = negatives.isEmpty ? nil : joinEmotions(negatives) + " were prominent. Take care, slow down, and reach out if needed."
        let neutralPart  = neutrals.isEmpty  ? nil : joinEmotions(neutrals) + " shaped the month—stay open and adaptable."
    
        
        let parts = [positivePart, negativePart, neutralPart].compactMap { $0 }
        if parts.isEmpty {
            return "A mixed month—stay mindful and take care."
        }
        return parts.joined(separator: " ")
    }
    
    private func joinEmotions(_ emotions: [EmotionType]) -> String {
        let names = emotions.map { $0.rawValue.capitalized }
        switch names.count {
        case 0: return ""
        case 1: return names[0]
        case 2: return "\(names[0]) and \(names[1])"
        default:
            let allButLast = names.dropLast().joined(separator: ", ")
            return "\(allButLast), and \(names.last!)"
        }
    }
    
    // MARK: - Recent Records
    
    var recentRecords: [DailyEmotionRecord] {
        dailyRecords.sorted { $0.date > $1.date }
    }
}
