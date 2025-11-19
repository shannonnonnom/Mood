//
//  EmotionType.swift
//  Mood
//
//  Created by Zih Syuan Kuo on 2025/11/16.
//

import SwiftUI

enum EmotionType: String, CaseIterable, Codable {
    case happy, sad, angry, surprised, fear, disgust, calm, excited
    
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .sad: return .blue
        case .angry: return .red
        case .surprised: return .orange
        case .fear: return .purple
        case .disgust: return .green
        case .calm: return .teal
        case .excited: return .pink
        }
    }
    
   
        }

