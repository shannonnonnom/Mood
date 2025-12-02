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
            
            // 直接在 Reflection 分頁內鋪背景，避免影響其他分頁
            ZStack {
                Image("CalendarBackground-4")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .containerRelativeFrame(.horizontal)
                    .overlay(
                        Color.black.opacity(0.12).ignoresSafeArea()
                    )
                
                // 內容保持透明，讓背景透出
                ReflectionListView()
                    .background(Color.clear)
            }
            .tabItem {
                Image(systemName: "book")
                Text("Reflection")
            }
            .tag(1)
            
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
            Image(imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Rectangle()
                .fill(Color.black.opacity(0.12))
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            content()
                .background(Color.clear)
                .zIndex(1)
        }
    }
}

#Preview {
    HomeView()
}
