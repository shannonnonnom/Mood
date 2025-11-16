//
//  ReflectionListView.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import SwiftUI

struct ReflectionListView: View {
    @ObservedObject var dataManager = EmotionDataManager.shared
    @State private var showDetail = false
    @State private var selectedRecord: DailyEmotionRecord?

    var body: some View {
        NavigationView {
            List(dataManager.recentRecords) { record in
                Button(action: {
                    // Always fetch the freshest copy before presenting
                    let fresh = dataManager.dailyRecord(for: record.date)
                    selectedRecord = fresh
                    showDetail = true
                }) {
                    HStack {
                        Text(record.dateString)
                        Spacer()
                        if let topEmotion = record.emotionPercentages.max(by: { $0.value < $1.value }),
                           topEmotion.value > 0 {
                            Text("\(topEmotion.key.rawValue.capitalized): \(Int(topEmotion.value))%")
                                .foregroundColor(topEmotion.key.color)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Reflections")
        }
        .sheet(isPresented: $showDetail) {
            if let record = selectedRecord {
                ReflectionDetailView(dailyRecord: record)
            }
        }
    }
}

struct ReflectionDetailView: View {
    @ObservedObject var dataManager = EmotionDataManager.shared
    @State var dailyRecord: DailyEmotionRecord
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Edit Your Reflection")
                    .font(.headline)
                
                TextEditor(text: $dailyRecord.notes)
                    .frame(height: 150)
                    .border(Color.gray)
                    .padding(.horizontal)
                
                Toggle("Private", isOn: $dailyRecord.isPrivate)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: saveRecord) {
                    Text("Save")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                }
            }
            .navigationTitle(dailyRecord.dateString)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            // Refresh with the latest saved content when opening detail
            dailyRecord = dataManager.dailyRecord(for: dailyRecord.date)
        }
    }
    
    private func saveRecord() {
        dataManager.save(record: dailyRecord)
        dismiss()
    }
}
