//
//  AVCaptureDevice.DiscoverySession.Extension.swift
//  MyCamera
//
//  Created by Aung Ko Min on 16/3/21.
//

import AVFoundation
import UIKit

extension AVCaptureDevice.DiscoverySession {
    
    var uniqueDevicePositionsCount: Int {
        var uniqueDevicePositions = [AVCaptureDevice.Position]()
        
        for device in devices where !uniqueDevicePositions.contains(device.position) {
            uniqueDevicePositions.append(device.position)
        }
        
        return uniqueDevicePositions.count
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension AVCaptureDevice.FlashMode {
    
    var imageName: String {
        switch self {
        case .on:
            return "bolt"
        case .off:
            return "bolt.slash"
        case .auto:
            return "bolt.badge.a"
        @unknown default:
            return "circle.fill"
        }
    }
    
    var description: String {
        switch self {
        case .auto:
            return "Auto"
        case .off:
            return "Off"
        case .on:
            return "On"
        @unknown default:
            return "Ukn"
        }
    }
}


extension AVCapturePhotoOutput.QualityPrioritization {
    func toggle() -> AVCapturePhotoOutput.QualityPrioritization {
        switch self {
        case .speed:
            return .balanced
        case .balanced:
            return .quality
        case .quality:
            return .speed
        @unknown default:
            return .speed
        }
    }
    
    var description: String {
        switch self {
        case .speed:
            return "Speed"
        case .balanced:
            return "Balanced"
        case .quality:
            return "Quality"
        @unknown default:
            return "Speed"
        }
    }
}
