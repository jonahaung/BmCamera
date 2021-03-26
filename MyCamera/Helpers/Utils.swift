import UIKit
import AVFoundation

class Utils {

    // Subscribes target to default NotificationCenter .UIDeviceOrientationDidChange
    static func subscribeToDeviceOrientationNotifications(_ target: AnyObject, selector: Selector) {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        let center = NotificationCenter.default
        let name =  UIDevice.orientationDidChangeNotification
        let selector = selector
        center.addObserver(target, selector: selector, name: name, object: nil)
    }

    static func unsubscribeFromOrientationNotifications(_ target: AnyObject) {
        let center = NotificationCenter.default
        center.removeObserver(target)

        //UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    static func videoOrientationFromDeviceOrientation(
        videoOrientation: AVCaptureVideoOrientation) -> AVCaptureVideoOrientation {
        let deviceOrientation = UIDevice.current.orientation

        switch deviceOrientation {
        case .unknown:
            return videoOrientation
        case .portrait:
            // Device oriented vertically, home button on the bottom
            return .portrait
        case .portraitUpsideDown:
            // Device oriented vertically, home button on the top
            return .portraitUpsideDown
        case .landscapeLeft:
            // Device oriented horizontally, home button on the right
            return .landscapeRight
        case .landscapeRight:
            // Device oriented horizontally, home button on the left
            return .landscapeLeft
        case .faceUp:
            // Device oriented flat, face up
            return videoOrientation
        case .faceDown:
            // Device oriented flat, face down
            return videoOrientation
				@unknown default:
						fatalError()
			}
    }

    static func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let deviceOrientation = UIDevice.current.orientation

        switch deviceOrientation {
        case .portraitUpsideDown:  // Device oriented vertically, home button on the top
            return .left
        case .landscapeLeft:       // Device oriented horizontally, home button on the right
            return .upMirrored
        case .landscapeRight:      // Device oriented horizontally, home button on the left
            return .down
        case .portrait:            // Device oriented vertically, home button on the bottom
            return .up
        default:
            return .up
        }
    }

    static func imageOrientationFromInterfaceOrientation() -> UIImage.Orientation {
        let interfaceOrientation = UIDevice.current.orientation
        switch interfaceOrientation {
        case .portrait:
            return .right
        case .portraitUpsideDown:
            return .left
        case .landscapeRight:
            return .up
        case .landscapeLeft:
            return .down

        default:
            return .right
        }
    }

    static func contentModeFromInterfaceOrientation(for image: UIImage) -> UIView.ContentMode {
        let interfaceOrientation = UIApplication.shared.supportedInterfaceOrientations(for: UIApplication.shared.windows.first)
        let imageOrientation = image.imageOrientation
        
        switch (interfaceOrientation, imageOrientation) {
        case (.portrait, .right),
             (.portrait, .left),

             (.portraitUpsideDown, .left),
             (.portraitUpsideDown, .right),

             (.landscapeLeft, .up),
             (.landscapeLeft, .down),

             (.landscapeRight, .up),
             (.landscapeRight, .down):
            return .scaleAspectFill

        default:
            return .scaleAspectFit
        }
    }
    
    static func isPotrait () -> Bool {
        if UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isPortrait ?? true {
            return true
        }
        return false
    }
    
    static var orientationLock = UIInterfaceOrientationMask.all
    
    static func createDefaultPhotos() {
        
        if let data = UIImage(named: "cat")?.jpegData(compressionQuality: 1) {
            _ = Photo.create(data: data, isVideo: false)
        }
        if let data = UIImage(named: "dog")?.jpegData(compressionQuality: 1) {
            _ = Photo.create(data: data, isVideo: false)
        }
        if let data = UIImage(named: "beach")?.jpegData(compressionQuality: 1) {
            _ = Photo.create(data: data, isVideo: false)
        }
        
    }

}

 let relativeDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
    formatter.doesRelativeDateFormatting = true
        return formatter
    }()
