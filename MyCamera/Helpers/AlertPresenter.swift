//
//  AlertPresenter.swift
//  MyCamera
//
//  Created by Aung Ko Min on 17/3/21.
//

import Foundation
import UIKit

typealias Action = () -> Void
typealias ActionPair = (String, Action)

struct AlertPresenter {
    
    static func presentActionSheet(title: String? = nil , message: String? = nil, actions: [ActionPair]) {
        SoundManager.vibrate(vibration: .medium)
        let x = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        
        actions.forEach{ action in
            let alertAction = UIAlertAction(title: action.0, style: .default) { _ in
                action.1()
            }
            x.addAction(alertAction)
        }
        
        x.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        UIApplication.getTopViewController()?.present(x, animated: true, completion: nil)
    }
    
    static func show(title: String, message: String? = nil) {
        let x = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        x.addAction(UIAlertAction(title: "OK", style: .cancel))
        UIApplication.getTopViewController()?.present(x, animated: true, completion: nil)
    }
    
}

