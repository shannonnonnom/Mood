//
//  AlertHelper.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import SwiftUI

struct AlertHelper {
    static func simpleAlert(title: String, message: String) -> Alert {
        Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
    }
    
    static func confirmAlert(title: String, message: String, confirmAction: @escaping () -> Void) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            primaryButton: .default(Text("Confirm"), action: confirmAction),
            secondaryButton: .cancel()
        )
    }
}
