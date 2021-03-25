//
//  SettingsManager.swift
//  MyCamera
//
//  Created by Aung Ko Min on 17/3/21.
//

import UIKit
import MessageUI
import StoreKit

class SettingManager: NSObject {
    
    static let shared = SettingManager()
    func gotoPrivacyPolicy() {
        guard let url = URL(string: "https://mmsgr-1b7a6.web.app") else {
            return //be safe
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func rateApp() {
        for scene in UIApplication.shared.connectedScenes {
                        if scene.activationState == .foregroundActive {
                            if let windowScene = scene as? UIWindowScene {
                                SKStoreReviewController.requestReview(in: windowScene)
                            }
                            
                            break
                        }
                    }
        
    }
    
    func shareApp() {
        if let url = URL(string: "https://apps.apple.com/app/myanmar-lens/id1489326871") {
            url.shareWithMenu()
        }
    }
    
    func gotoDeviceSettings() {
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url, options: [:]) { _ in
            
        }
    }
    
   
    func gotoContactUs() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Myanmar Lens: Feedback")
            mail.setToRecipients(["jonahaung@gmail.com"])
            
            UIApplication.getTopViewController()?.present(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
}

extension SettingManager: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            switch result {
            case .sent:
                AlertPresenter.show(title: "Thank you for contacting us. I will get back to you soon. Have a nice day.\nAung Ko Min")
            case .failed:
                AlertPresenter.show(title: "Failed to send Mail")
            default:
                break
            }
        }
    }
}

extension Equatable {
    func shareWithMenu() {
        let activity = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
        
        let root = UIApplication.getTopViewController()?.view
        
        if isPad, let source = root {
           
            activity.popoverPresentationController?.sourceView = source
            activity.popoverPresentationController?.sourceRect = CGRect(x: source.bounds.midX, y: source.bounds.midY, width: 0, height: 0)
            activity.popoverPresentationController?.permittedArrowDirections = .down
            activity.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        }
        UIApplication.getTopViewController()?.present(activity, animated: true, completion: nil)
    }
}

extension Bundle {
    var version: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
