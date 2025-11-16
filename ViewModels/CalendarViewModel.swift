//
//  CalendarViewModel.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import Foundation
import SwiftUI
import Combine

class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var showDailySheet = false

    // Keep a reference to the shared manager. Views observing this VM will update
    // when data is fetched via the manager or when you mutate @Published state here.
    let dataManager = EmotionDataManager.shared

    init() { }

    func getRecord(for date: Date) -> DailyEmotionRecord {
        return dataManager.dailyRecord(for: date)
    }

    func save(record: DailyEmotionRecord) {
        dataManager.save(record: record)
    }
}
