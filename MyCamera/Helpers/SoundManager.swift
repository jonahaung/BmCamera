//
//  SoundManager.swift
//  MyCamera
//
//  Created by Aung Ko Min on 11/3/21.
//

import Foundation
import UIKit
import AudioToolbox

enum AlertTones: SystemSoundID {
    
    case MailSent = 1001
    case MailReceived = 1000
    case receivedMessage = 1003
    case sendMessage = 1004
    case Tock = 1105
    case Typing = 1305
}

enum Vibration {
    case error
    case success
    case warning
    case soft
    case rigid
    case selection
    case oldSchool
    
    func vibrate() {
        
        switch self {
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        case .oldSchool:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        case .soft:
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        case .rigid:
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }
        
    }
    
}


final class SoundManager {

    class func playSound(tone: AlertTones) {
        AudioServicesPlaySystemSoundWithCompletion(tone.rawValue) {
            AudioServicesDisposeSystemSoundID(tone.rawValue)
        }

    }
    
    
    class func vibrate(vibration: Vibration) {
        vibration.vibrate()
    }
}
