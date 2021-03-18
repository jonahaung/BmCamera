//
//  UserdefaultManager.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import AVFoundation

class UserdefaultManager {
    
    static let shared = UserdefaultManager()
    private let manager = UserDefaults.standard
    let _currentFolderName = "currentFolderName"
    private let _passwords = "passwords"
    let _hasShownOnboarding = "hasShownOnboarding"
    let _doneSetup = "doneSetup"
    let _offShutterSound = "playShutterSound"
    let _flashMode = "flashMode"
    
    var currentFolderName: String? {
        get {
            return manager.string(forKey: _currentFolderName)
        }
        set {
            manager.setValue(newValue, forKey: _currentFolderName)
        }
    }
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
    
    var hasShownOnboarding: Bool {
        get {
            return manager.bool(forKey: _hasShownOnboarding)
        }
        set {
            manager.setValue(newValue, forKey: _hasShownOnboarding)
        }
    }
    var doneSetup: Bool {
        get {
            return manager.bool(forKey: _doneSetup)
        }
        set {
            manager.setValue(newValue, forKey: _doneSetup)
        }
    }
    var offShutterSound: Bool {
        get {
            return manager.bool(forKey: _offShutterSound)
        }
        set {
            manager.setValue(newValue, forKey: _offShutterSound)
        }
    }
    
    var flashMode: AVCaptureDevice.FlashMode {
        get {
            return AVCaptureDevice.FlashMode(rawValue: manager.integer(forKey: _flashMode)) ?? .off
        }
        set {
            manager.setValue(newValue.rawValue, forKey: _flashMode)
        }
    }
}
