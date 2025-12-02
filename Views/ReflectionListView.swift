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
          
            Image("CalendarBackground-4")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .containerRelativeFrame(.horizontal)
                .overlay(
                    Color.black.opacity(0.12).ignoresSafeArea()
                )

           
            NavigationView {
                List(dataManager.recentRecords) { record in
                    Button(action: {
                        let fresh = dataManager.dailyRecord(for: record.date)
                        selectedRecord = fresh
                        showDetail = true
                    }) {
                        HStack {
                            Text(record.dateString)
                            Spacer()
                            HStack(spacing: 6) {
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
                
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .onAppear {
                    
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
                    .background(
                        ZStack {
                            
                            Image("CalendarBackground-4")
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                                .containerRelativeFrame(.horizontal)
                                .overlay(
                                    Color.black.opacity(0.12).ignoresSafeArea()
                                )
                        }
                    )
            }
        }
    }
}

struct ReflectionDetailView: View {
    @ObservedObject var dataManager = EmotionDataManager.shared
    @State var dailyRecord: DailyEmotionRecord
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            
            Image("CalendarBackground-4")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .containerRelativeFrame(.horizontal)
                .overlay(
                    Color.black.opacity(0.12).ignoresSafeArea()
                )
            
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
            .background(Color.clear)
        }
        .onAppear {
            // 開啟時刷新最新內容
            dailyRecord = dataManager.dailyRecord(for: dailyRecord.date)
        }
    }
    
    private func saveRecord() {
        dataManager.save(record: dailyRecord)
        dismiss()
    }
}
