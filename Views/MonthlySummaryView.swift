//
//  MonthlySummaryView.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import SwiftUI
import Charts

struct MonthlySummaryView: View {
    @ObservedObject var dataManager = EmotionDataManager.shared
    @State private var selectedMonth = Date()
    
    private var monthStart: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: selectedMonth)) ?? selectedMonth
    }
    
    var body: some View {
        ZStack {
            // 背景-4
            Image("CalendarBackground-4")
                .resizable()
                .scaledToFill()
                .containerRelativeFrame(.horizontal)
                .ignoresSafeArea()
                .overlay(
                    Color.white.opacity(0.28).ignoresSafeArea()
                )
            
            VStack(spacing: 20) {
                HStack {
                    Text("Select Month")
                    Spacer()
                    Menu(monthStart.monthString()) {
                        ForEach(monthOptions, id: \.self) { month in
                            Button(month.monthString()) {
                                selectedMonth = month
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // 心情統計圖表
                MoodChartView(month: monthStart)
                    .frame(height: 300)
                
                // 小語
                Text(dataManager.smallMessage(for: monthStart))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .navigationTitle("Monthly Summary")
            .onAppear {
                normalizeSelectedMonth()
            }
            .onChange(of: selectedMonth) { _ in
                normalizeSelectedMonth()
            }
        }
    }
    
    private var monthOptions: [Date] {
        let cal = Calendar.current
        let now = Date()
        let startOfThisMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? now
        return (0..<24).compactMap { offset in
            cal.date(byAdding: .month, value: -offset, to: startOfThisMonth)
        }.reversed()
    }
    
    private func normalizeSelectedMonth() {
        let cal = Calendar.current
        if let normalized = cal.date(from: cal.dateComponents([.year, .month], from: selectedMonth)) {
            if normalized != selectedMonth {
                selectedMonth = normalized
            }
        }
    }
}

struct MoodChartView: View {
    var month: Date
    @ObservedObject var dataManager = EmotionDataManager.shared
    
    var body: some View {
        let summary = dataManager.monthlySummary(for: month)
        
        Chart {
            ForEach(EmotionType.allCases, id: \.self) { emotion in
                BarMark(
                    x: .value("Emotion", emotion.rawValue.capitalized),
                    y: .value("Percentage", summary[emotion] ?? 0)
                )
                .foregroundStyle(emotion.color.gradient)
                .annotation(position: .top) {
                    let value = summary[emotion] ?? 0
                    Text("\(Int(value))%")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .opacity(value > 0 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: value)
                }
            }
        }
        .chartYAxisLabel("Mood %")
        .chartXAxisLabel("Emotion")
        .padding()
        .animation(.easeInOut(duration: 0.5), value: summary)
    }
}

