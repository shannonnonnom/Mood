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
            
            
    
            BackgroundTab(imageName: "CalendarBackground-2") {
                ReflectionListView()
                    .background(Color.clear)
            }
            .tabItem {
                Image(systemName: "book")
                Text("Reflection")
            }
            .tag(1)
            
            // 分頁 3：Summary（維持原樣，無背景圖）
            MonthlySummaryView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Summary")
                }
                .tag(2)
        }
    }
}

private struct BackgroundTab<Content: View>: View {
    let imageName: String
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            // 背景圖層
            Image(imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // 可讀性遮罩（可調整或移除）
            Rectangle()
                .fill(Color.black.opacity(0.12))
                .ignoresSafeArea()
            
            // 內容
            content()
                .background(Color.clear)
        }
        // 再加一層背景，避免個別容器有自身背景時蓋掉
        .background(
            Image(imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

#Preview {
    HomeView()
}
