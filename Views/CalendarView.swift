//
//  CalendarView.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import SwiftUI

// 假設已經有 EmotionDataManager & DailyEmotionRecord 定義

struct CalendarView: View {
    @State private var currentMonth: Date = Date() // 顯示中的月份（正規化到月初）
    @State private var selectedDate = Date()
    @State private var showDailySheet = false

    @ObservedObject var dataManager = EmotionDataManager.shared

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let weekSymbols = Calendar.current.shortWeekdaySymbols // ["Sun","Mon",...]

    var body: some View {
        ZStack {
            // 背景圖層（Calendar 首頁底圖）
            Image("CalendarBackground-1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // 可讀性遮罩（可依需求調整或移除）
            Rectangle()
                .fill(Color.black.opacity(0.12))
                .ignoresSafeArea()

            NavigationView {
                ScrollViewReader { proxy in
                    ScrollView {
                        // Page 1: Today 快速填寫（滿版）
                        VStack(spacing: 16) {
                            Spacer()

                            Text("Quick Entry")
                                .font(.headline)
                                .padding(.top, 8)

                            Button(action: {
                                selectedDate = Date()
                                showDailySheet = true
                            }) {
                                Text("Record Mood for Today")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                            }
                            .padding(.horizontal)

                            Button {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo("CalendarSection", anchor: .top)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Choose another day")
                                    Image(systemName: "arrow.down")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.orange)
                                .padding(.top, 8)
                            }

                            Spacer()
                        }
                        .frame(minHeight: UIScreen.main.bounds.height * 0.85) // 幾乎滿版
                        .frame(maxWidth: .infinity)
                        .id("TopSection")

                        // Page 2: 月曆（移至頂部）
                        VStack(spacing: 16) {
                            // 月份切換列
                            HStack {
                                Button {
                                    changeMonth(by: -1)
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.headline)
                                }
                                Spacer()
                                Text(titleForMonth(currentMonth))
                                    .font(.title3).bold()
                                Spacer()
                                Button {
                                    changeMonth(by: 1)
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)

                            // 週標題
                            HStack {
                                ForEach(weekSymbols, id: \.self) { symbol in
                                    Text(symbol)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 6)

                            // 月曆網格
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(daysForMonth(currentMonth), id: \.self) { day in
                                    DayCellView(
                                        date: day,
                                        month: currentMonth,
                                        hasRecord: hasRecord(on: day),
                                        isToday: Calendar.current.isDateInToday(day)
                                    )
                                    .onTapGesture {
                                        guard isInSameMonth(day, as: currentMonth) else { return }
                                        selectedDate = day
                                        showDailySheet = true
                                    }
                                }
                            }
                            .padding(.horizontal, 6)

                            // 返回頂部
                            Button {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo("TopSection", anchor: .top)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.up")
                                    Text("Back to Today quick entry")
                                }
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                            }

                            Spacer(minLength: 8)
                        }
                        .id("CalendarSection")
                        .frame(minHeight: UIScreen.main.bounds.height * 0.85) // 保持與第一頁高度一致的視覺連貫
                    }
                    // 隱藏 ScrollView 預設背景
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .navigationTitle("Calendar")
                    .onAppear {
                        currentMonth = monthStart(for: currentMonth)
                        // 清除導航欄背景，讓底圖透出
                        let appearance = UINavigationBarAppearance()
                        appearance.configureWithTransparentBackground()
                        UINavigationBar.appearance().standardAppearance = appearance
                        UINavigationBar.appearance().scrollEdgeAppearance = appearance
                    }
                }
            }
            // 讓 NavigationView 背景透明
            .background(Color.clear)
        }
        .sheet(isPresented: $showDailySheet) {
            DailyMoodSheetView(date: selectedDate)
        }
    }

    // MARK: - Helpers

    private func titleForMonth(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: date)
    }

    private func changeMonth(by offset: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = monthStart(for: newMonth)
        }
    }

    private func monthStart(for date: Date) -> Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: date)) ?? date
    }

    private func isInSameMonth(_ date: Date, as month: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: month, toGranularity: .month)
    }

    private func daysForMonth(_ month: Date) -> [Date] {
        let cal = Calendar.current
        let startOfMonth = monthStart(for: month)
        guard
            let range = cal.range(of: .day, in: .month, for: startOfMonth),
            let firstWeekday = cal.dateComponents([.weekday], from: startOfMonth).weekday
        else { return [] }

        // 計算前置空格（以系統 firstWeekday 對齊）
        let leadingEmpty = (firstWeekday - cal.firstWeekday + 7) % 7

        // 本月所有日期
        let monthDays: [Date] = range.compactMap { day -> Date? in
            cal.date(byAdding: DateComponents(day: day - 1), to: startOfMonth)
        }

        // 前置補齊（顯示上個月尾巴的日期，作為禁用狀態）
        var days: [Date] = []
        if leadingEmpty > 0 {
            for i in 1...leadingEmpty {
                if let d = cal.date(byAdding: .day, value: -leadingEmpty + (i - 1), to: startOfMonth) {
                    days.append(d)
                }
            }
        }

        // 將本月日期加入
        days.append(contentsOf: monthDays)

        // 補滿到 6 週（42 格），讓格子高度穩定
        while days.count % 7 != 0 {
            if let last = days.last,
               let next = cal.date(byAdding: .day, value: 1, to: last) {
                days.append(next)
            }
        }
        while days.count < 42 {
            if let last = days.last,
               let next = cal.date(byAdding: .day, value: 1, to: last) {
                days.append(next)
            }
        }

        return days
    }

    private func hasRecord(on date: Date) -> Bool {
        dataManager.dailyRecords.contains { Calendar.current.isDate($0.date, inSameDayAs: date) && !$0.isEmpty }
    }
}

// MARK: - Day Cell

private struct DayCellView: View {
    let date: Date
    let month: Date
    let hasRecord: Bool
    let isToday: Bool

    var body: some View {
        let inMonth = Calendar.current.isDate(date, equalTo: month, toGranularity: .month)
        let day = Calendar.current.component(.day, from: date)

        VStack(spacing: 4) {
            Text("\(day)")
                .font(.subheadline)
                .fontWeight(isToday && inMonth ? .bold : .regular)
                .foregroundColor(inMonth ? .primary : .gray)
                .frame(maxWidth: .infinity)
                .padding(.top, 6)

            // 有紀錄顯示小圓點
            Circle()
                .fill(hasRecord ? Color.green : Color.clear)
                .frame(width: 6, height: 6)
                .opacity(inMonth ? 1 : 0)
                .padding(.bottom, 6)
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                if isToday && inMonth {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                        .opacity(0.8)
                }
            }
        )
        .contentShape(Rectangle())
        .opacity(inMonth ? 1 : 0.4)
    }
}

// MARK: - Sheet

struct DailyMoodSheetView: View {
    var date: Date
    @ObservedObject var dataManager = EmotionDataManager.shared

    @State private var dailyRecord: DailyEmotionRecord
    @State private var showAlert = false
    @State private var showConfirm = false
    @Environment(\.dismiss) private var dismiss

    init(date: Date) {
        self.date = date
        _dailyRecord = State(initialValue: EmotionDataManager.shared.dailyRecord(for: date))
    }

    var body: some View {
        NavigationView {
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
                    // 確認提示
                    .alert(isPresented: $showConfirm) {
                        AlertHelper.confirmAlert(
                            title: "Saved",
                            message: "Your mood has been saved.",
                            confirmAction: {
                                dismiss()
                            }
                        )
                    }
                }
                .padding(.vertical)
            }
            .onAppear {
                // 確保載入該日期的最新資料
                dailyRecord = dataManager.dailyRecord(for: date)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func saveRecord() {
        if dailyRecord.isEmpty {
            showAlert = true
        } else {
            dataManager.save(record: dailyRecord)
            // 顯示確認視窗，點擊確認後關閉
            showConfirm = true
        }
    }
}
