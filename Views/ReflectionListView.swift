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
        ZStack {
            // 背景圖層（改為在此檔案中設定）
            

            // 可讀性遮罩（可調整或移除）
            Rectangle()
                .fill(Color.black.opacity(0.12))
                .ignoresSafeArea()

            // 主要內容
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
                            HStack(spacing: 6) {
                                // 依 EmotionType 固定順序，挑出當天有紀錄 (> 0) 的情緒，顯示顏色小圓點
                                ForEach(EmotionType.allCases.filter { (record.emotionPercentages[$0] ?? 0) > 0 }, id: \.self) { emotion in
                                    Circle()
                                        .fill(emotion.color)
                                        .frame(width: 10, height: 10)
                                        .accessibilityLabel(Text(emotion.rawValue.capitalized))
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Reflections")
                // 隱藏列表的預設背景，讓底圖透出
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .onAppear {
                    // 讓導航欄透明，避免覆蓋背景
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithTransparentBackground()
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
            }
            .background(Color.clear)
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
