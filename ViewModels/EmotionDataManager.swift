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
    
    func smallMessage(for month: Date) -> String {
        let summary = monthlySummary(for: month)
        if let (emotion, value) = summary.max(by: { $0.value < $1.value }), value > 0 {
            switch emotion {
            case .happy: return "Looks like a joyful month!"
            case .sad: return "Some sad days, take care of yourself."
            case .angry: return "A challenging month, remember to breathe."
            case .surprised: return "Lots of surprises this month!"
            case .fear: return "A month of caution, stay strong."
            case .disgust: return "Some moments were tough, stay positive."
            case .calm: return "You had a calm and peaceful month."
            case .excited: return "Exciting month, keep the energy!"
            }
        } else {
            return "No mood recorded this month."
        }
    }
    
    // MARK: - Recent Records
    
    var recentRecords: [DailyEmotionRecord] {
        dailyRecords.sorted { $0.date > $1.date }
    }
}
