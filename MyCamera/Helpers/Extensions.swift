//
//  Extensions.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import UIKit
import AVKit
import SwiftUI

extension EditMode {
    
    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}


extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {

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

    return scaledWithMaxWidthOrHeightValue(value: UIScreen.main.bounds.width)

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
            let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
            return thumbNailImage
        } catch {
            print(error.localizedDescription) //10
            return nil
        }
    }
}
