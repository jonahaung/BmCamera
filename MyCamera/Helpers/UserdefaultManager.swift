//
//  UserdefaultManager.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import AVFoundation
import SwiftUI

class UserdefaultManager {
    
    static let shared = UserdefaultManager()
    private let manager = UserDefaults.standard
    
    let _currentFolderName = "currentFolderName"
    let _passwords = "passwords"
    let _hasShownOnboarding = "hasShownOnboarding"
    let _doneSetup = "doneSetup"
    let _offShutterSound = "playShutterSound"
    let _flashMode = "flashMode"
    let _currentGrid = "_currentGrid"
    let _fontDesign = "fontDesign"
    let _photoQualityPrioritizationMode = "photoQualityPrioritizationMode"
    var passWords: [String] {
        get {
            guard let data = UserDefaults.standard.object(forKey: _passwords) as? Data, let passwords = (try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data)) as? [String]  else {
                print("'places' not found in UserDefaults")
                return []
            }
            return passwords
        }
        set {
            do {
                let placesData = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)
                    UserDefaults.standard.set(placesData, forKey: _passwords)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    var fontDesign: FontDesign {
        get {
            return FontDesign(rawValue: manager.integer(forKey: _fontDesign)) ?? .rounded
        }
        set {
            manager.setValue(newValue.rawValue, forKey: _fontDesign)
        }
    }
    var currentFolderName: String? {
        get { return manager.string(forKey: _currentFolderName) }
        set { manager.setValue(newValue, forKey: _currentFolderName) }
    }
    
    var hasShownOnboarding: Bool {
        get { return manager.bool(forKey: _hasShownOnboarding) }
        set { manager.setValue(newValue, forKey: _hasShownOnboarding) }
    }
    
    var doneSetup: Bool {
        get { return manager.bool(forKey: _doneSetup) }
        set { manager.setValue(newValue, forKey: _doneSetup) }
    }
    
    var offShutterSound: Bool {
        get { return manager.bool(forKey: _offShutterSound) }
        set { manager.setValue(newValue, forKey: _offShutterSound) }
    }
    
    var flashMode: AVCaptureDevice.FlashMode {
        get {
            let rawValue = manager.integer(forKey: _flashMode)
            
            return AVCaptureDevice.FlashMode(rawValue: rawValue) ?? .off
        }
        set { manager.setValue(newValue.rawValue, forKey: _flashMode) }
    }
    
    var currentGrid: Int {
        get { return manager.integer(forKey: _currentGrid) }
        set { manager.setValue(newValue, forKey: _currentGrid) }
    }
    
    var photoQualityPrioritizationMode: AVCapturePhotoOutput.QualityPrioritization {
        get {
            var rawValue = manager.integer(forKey: _photoQualityPrioritizationMode)
            if rawValue == 0 {
                manager.setValue(1, forKey: _photoQualityPrioritizationMode)
                rawValue = 1
            }
            return AVCapturePhotoOutput.QualityPrioritization(rawValue: rawValue) ?? .speed
        }
        set {
            manager.setValue(newValue.rawValue, forKey: _photoQualityPrioritizationMode)
        }
    }
    
}

enum FontDesign: Int, CaseIterable {
    
    case rounded, monoSpaced, serif
    
    var design: Font.Design {
        switch self {
        case .rounded:
            return .rounded
        case .monoSpaced:
            return .monospaced
        case .serif:
            return .serif
        }
    }
    
    var name: String {
        switch self {
        case .monoSpaced:
            return "Monospaced"
        case .serif:
            return "Serif"
        case .rounded:
            return "Rounded"
        }
    }
}
