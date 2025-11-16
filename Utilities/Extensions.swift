//
//  Extensions.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import SwiftUI

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
    
    func monthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
}

extension View {
    func roundedShadow(cornerRadius: CGFloat = 10, shadowRadius: CGFloat = 3) -> some View {
        self
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
    }
}
