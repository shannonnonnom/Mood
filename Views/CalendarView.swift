//
//  CalendarView.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentMonth: Date = Date()
    @State private var selectedDate = Date()
    @State private var showDailySheet = false

    @ObservedObject var dataManager = EmotionDataManager.shared

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let weekSymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        ZStack {
            NavigationView {
                ScrollViewReader { proxy in
                    ScrollView {
                        
                        ZStack {
                            Image("CalendarBackground-1")
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                                .overlay(
                                    Color.white.opacity(0.28).ignoresSafeArea()
                                )

                            VStack(spacing: 24) {
                                Spacer(minLength: 60)

                               
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        selectedDate = Date()
                                        showDailySheet = true
                                    }) {
                                        Text("Record Mood for Today")
                                            .font(.title3.weight(.semibold))
                                            .padding(.horizontal, 28)
                                            .padding(.vertical, 16)
                                            .frame(minWidth: 220, minHeight: 54)
                                            .background(Color(red: 250/255, green: 192/255, blue: 61/255))
                                            .opacity(0.9)
                                            .foregroundColor(.white)
                                            .cornerRadius(14)
                                            .shadow(radius: 6)
                                    }
                                    .contentShape(Rectangle())
                                    Spacer()
                                }
                                .padding(.horizontal)

                                Button {
                                    withAnimation(.easeInOut) {
                                        proxy.scrollTo("CalendarSection", anchor: .top)
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Text("Choose another day")
                                            .font(.body.weight(.semibold))
                                        Image(systemName: "arrow.down.circle.fill")
                                            .font(.body.bold())
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule().fill(
                                            Color(red: 0.98, green: 0.69, blue: 0.35).opacity(0.8) //
                                        )
                                    )
                                    .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
                                }
                                .contentShape(Rectangle())

                                Spacer()
                            }
                            .frame(minHeight: UIScreen.main.bounds.height * 0.85)
                            .frame(maxWidth: .infinity)
                        }
                        .id("TopSection")

                       
                        ZStack {
                            Image("CalendarBackground-2")
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                                .overlay(
                                    Color.white.opacity(0.28).ignoresSafeArea()
                                )

                            VStack {
                                Spacer(minLength: 20)

                                VStack(spacing: 16) {
                                    
                                    HStack {
                                        Button {
                                            changeMonth(by: -1)
                                        } label: {
                                            Image(systemName: "chevron.left")
                                                .font(.headline)
                                        }
                                        Spacer()
                                        Text(titleForMonth(currentMonth))
                                            .font(.title2).bold()
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

                                    
                                    HStack {
                                        ForEach(weekSymbols, id: \.self) { symbol in
                                            Text(symbol)
                                                .font(.callout)
                                                .foregroundColor(.secondary)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .padding(.horizontal, 6)

                                   
                                    LazyVGrid(columns: columns, spacing: 12) {
                                        ForEach(daysForMonth(currentMonth), id: \.self) { day in
                                            DayCellView(
                                                date: day,
                                                month: currentMonth,
                                                hasRecord: hasRecord(on: day),
                                                isToday: Calendar.current.isDateInToday(day),
                                                largeStyle: true
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
                                        HStack(spacing: 8) {
                                            Image(systemName: "arrow.up.circle.fill")
                                                .font(.body.bold())
                                            Text("Back to Today")
                                                .font(.body.weight(.semibold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule().fill(Color(red: 0.46, green: 0.78, blue: 0.64))
                                        )
                                        .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
                                    }
                                    .padding(.top, 4)
                                    .padding(.bottom, 12)
                                    .zIndex(10)
                                    .accessibilityLabel("Back to Today")
                                }

                                Spacer(minLength: 20)
                            }
                            .frame(minHeight: UIScreen.main.bounds.height * 0.85)
                            .frame(maxWidth: .infinity)
                        }
                        .id("CalendarSection")
                       
                        .safeAreaInset(edge: .bottom) {
                            Color.clear
                                .frame(height: 28)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(
                        Image("CalendarBackground-1")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .overlay(
                                Color.white.opacity(0.28).ignoresSafeArea()
                            )
                    )
                    .navigationTitle("Calendar")
                    .onAppear {
                        currentMonth = monthStart(for: currentMonth)
                        let appearance = UINavigationBarAppearance()
                        appearance.configureWithTransparentBackground()
                        UINavigationBar.appearance().standardAppearance = appearance
                        UINavigationBar.appearance().scrollEdgeAppearance = appearance
                    }
                }
            }
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

        let leadingEmpty = (firstWeekday - cal.firstWeekday + 7) % 7

        let monthDays: [Date] = range.compactMap { day -> Date? in
            cal.date(byAdding: DateComponents(day: day - 1), to: startOfMonth)
        }

        var days: [Date] = []
        if leadingEmpty > 0 {
            for i in 1...leadingEmpty {
                if let d = cal.date(byAdding: .day, value: -leadingEmpty + (i - 1), to: startOfMonth) {
                    days.append(d)
                }
            }
        }

        days.append(contentsOf: monthDays)

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
    var largeStyle: Bool = false

    var body: some View {
        let inMonth = Calendar.current.isDate(date, equalTo: month, toGranularity: .month)
        let day = Calendar.current.component(.day, from: date)

        VStack(spacing: largeStyle ? 6 : 4) {
            Text("\(day)")
                .font(largeStyle ? .headline : .subheadline)
                .fontWeight(isToday && inMonth ? .bold : .regular)
                .foregroundColor(inMonth ? .primary : .gray)
                .frame(maxWidth: .infinity)
                .padding(.top, largeStyle ? 8 : 6)

            Circle()
                .fill(hasRecord ? Color.green : Color.clear)
                .frame(width: largeStyle ? 8 : 6, height: largeStyle ? 8 : 6)
                .opacity(inMonth ? 1 : 0)
                .padding(.bottom, largeStyle ? 8 : 6)
        }
        .frame(height: largeStyle ? 64 : 48)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                if isToday && inMonth {
                    RoundedRectangle(cornerRadius: largeStyle ? 10 : 8)
                        .stroke(Color.blue, lineWidth: largeStyle ? 1.5 : 1)
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
            showConfirm = true
        }
    }
}

#Preview {
    HomeView() // Preview Home to test tab interaction
}
