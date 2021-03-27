//
//  Extensions.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import UIKit
import AVKit
import SwiftUI

extension UIApplication {
    
    class func getRootViewController() -> UIViewController? {
        var rootVC: UIViewController? = nil
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive {
                rootVC = ((scene as? UIWindowScene)!.delegate as! UIWindowSceneDelegate).window!!.rootViewController
                break
            }
        }
        return rootVC
    }
    class func getTopViewController(base: UIViewController? = UIApplication.getRootViewController()) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

extension UIImage {
    func resized(newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}


extension UIImage {
    
    func getThumbnail() -> UIImage? {
        
        return scaledWithMaxWidthOrHeightValue(value: 200)
        
    }
    func square() -> UIImage? {
            if size.width == size.height {
                return self
            }

            let cropWidth = min(size.width, size.height)

            let cropRect = CGRect(
                x: (size.width - cropWidth) * scale / 2.0,
                y: (size.height - cropWidth) * scale / 2.0,
                width: cropWidth * scale,
                height: cropWidth * scale
            )

            guard let imageRef = cgImage?.cropping(to: cropRect) else {
                return nil
            }

            return UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
        }
    func scaledWithMaxWidthOrHeightValue(value: CGFloat) -> UIImage? {
        
        let width = self.size.width
        let height = self.size.height
        
        let ratio = width/height
        
        var newWidth = value
        var newHeight = value
        
        if ratio > 1 {
            newWidth = width * (newHeight/height)
        } else {
            newHeight = height * (newWidth/width)
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0)
        
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func scaled(withScale scale: CGFloat) -> UIImage? {
        
        let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension Data {
    
    //    func decrypt() -> Data? {
    //        guard let folerName = UserdefaultManager.shared.currentFolderName else {
    //            return nil
    //        }
    //        do {
    //            let originalData = try RNCryptor.decrypt(data: self, withPassword: folerName)
    //            return originalData
    //            // ...
    //        } catch {
    //            print(error)
    //            return nil
    //        }
    //    }
    //
    //    func encrypt() -> Data? {
    //        guard let folerName = UserdefaultManager.shared.currentFolderName else {
    //            return nil
    //        }
    //        return RNCryptor.encrypt(data: self, withPassword: folerName)
    //    }
    
    var image: UIImage? {
        return UIImage(data: self)
    }
}

extension Int {
    var byteSize: String {
        return ByteCountFormatter().string(fromByteCount: Int64(self))
    }
}

extension Int {
    func secondsTodDuration() -> String {
        let h = self / 3600
        let m = (self % 3600) / 60
        let s = (self % 3600) % 60
        return h > 0 ? String(format: "%1d:%02d:%02d", h, m, s) : String(format: "%1d:%02d", m, s)
    }
}

extension URL {
    var data: Data? {
        return try? Data(contentsOf: self)
    }
    
    var videoThumbnil: UIImage? {
        let asset = AVAsset(url: self) //2
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
        avAssetImageGenerator.appliesPreferredTrackTransform = true //4
        let thumnailTime = CMTimeMake(value: 1, timescale: 1) //5
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
            let thumbNailImage = UIImage(cgImage: cgThumbImage).scaledWithMaxWidthOrHeightValue(value: 200) //7
            
            return thumbNailImage?.square()
        } catch {
            print(error.localizedDescription) //10
            return nil
        }
    }
}
