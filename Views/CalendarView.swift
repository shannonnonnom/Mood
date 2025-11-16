//
//  CalendarView.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import SwiftUI

// 假設已經有 EmotionDataManager & DailyEmotionRecord 定義

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var showDailySheet = false
    
    @ObservedObject var dataManager = EmotionDataManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 這裡使用簡單日曆替代第三方
                Text("Calendar Placeholder")
                    .font(.title2)
                    .padding()
                
                Button(action: {
                    showDailySheet = true
                }) {
                    Text("Record Mood for Today")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
            }
            .navigationTitle("Calendar")
        }
        .sheet(isPresented: $showDailySheet) {
            DailyMoodSheetView(date: selectedDate)
        }
    }
}

struct DailyMoodSheetView: View {
    var date: Date
    @ObservedObject var dataManager = EmotionDataManager.shared
    
    @State private var dailyRecord: DailyEmotionRecord
    @State private var showAlert = false
    @Environment(\.dismiss) private var dismiss
    
    init(date: Date) {
        self.date = date
        _dailyRecord = State(initialValue: EmotionDataManager.shared.dailyRecord(for: date))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Record Your Mood")
                    .font(.headline)
                
                ForEach(EmotionType.allCases, id: \.self) { emotion in
                    VStack {
                        HStack {
                            Text(emotion.rawValue.capitalized)
                            Spacer()
                            Text("\(Int(dailyRecord.emotionPercentages[emotion]!))%")
                                .foregroundColor(.gray)
                        }
                        Slider(
                            value: Binding(
                                get: { dailyRecord.emotionPercentages[emotion]! },
                                set: { dailyRecord.emotionPercentages[emotion]! = $0 }
                            ),
                            in: 0...100
                        )
                        .accentColor(emotion.color)
                        .animation(.easeInOut(duration: 0.3), value: dailyRecord.emotionPercentages[emotion])
                    }
                    .padding(.horizontal)
                }
                
                TextEditor(text: $dailyRecord.notes)
                    .frame(height: 100)
                    .border(Color.gray)
                    .padding(.horizontal)
                
                Toggle("Private", isOn: $dailyRecord.isPrivate)
                    .padding(.horizontal)
                
                Button(action: saveRecord) {
                    Text("Save")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                .padding(.horizontal)
                .alert("You haven't set any mood!", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
            .padding(.vertical)
        }
    }
    
    private func saveRecord() {
        if dailyRecord.isEmpty {
            showAlert = true
        } else {
            dataManager.save(record: dailyRecord)
            dismiss() // 保存成功后关闭弹窗，避免误以为未保存
        }
    }
}
