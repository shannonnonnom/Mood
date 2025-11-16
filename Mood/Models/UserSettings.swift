//
//  UserSettings.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import Foundation
import SwiftUI
import Combine

class UserSettings: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    static let shared = UserSettings()
    
    @AppStorage("userName") var userName: String = "User" {
        didSet { objectWillChange.send() }
    }
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true {
        didSet { objectWillChange.send() }
    }
    
    private init() {}
}
