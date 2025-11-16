//
//  ContentView.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(0)
            
            // 將 Reflection 放到第二個分頁
            ReflectionListView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Reflection")
                }
                .tag(1)
            
            // 將 Summary 放到第三個分頁
            MonthlySummaryView()
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Summary")
                }
                .tag(2)
        }
    }
}

#Preview {
    HomeView()
}
