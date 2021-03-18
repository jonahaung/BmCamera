//
//  Extensions.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import UIKit
import AVKit

extension UIImage: Identifiable {
    public var id: UIImage { self }
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

extension URL: Identifiable {
    public var id: URL {
        return self
    }
}
extension UIImage {

  func getThumbnail() -> UIImage? {

    return scaledWithMaxWidthOrHeightValue(value: 50)

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

