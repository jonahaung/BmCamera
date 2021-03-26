//
//  AlertPresenter.swift
//  MyCamera
//
//  Created by Aung Ko Min on 17/3/21.
//

import Foundation
import UIKit

typealias Action = () -> Void
typealias ActionPair = (String, Action, style: UIAlertAction.Style)

struct AlertPresenter {
    
    static func presentActionSheet(title: String? = nil , message: String? = nil, actions: [ActionPair]) {
        let x = UIAlertController(title: title, message: message, preferredStyle: .alert)

        
        actions.forEach{ action in
            let alertAction = UIAlertAction(title: action.0, style: action.style) { _ in
                action.1()
            }
            x.addAction(alertAction)
        }
        
        x.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        UIApplication.getTopViewController()?.present(x, animated: true)
    }
    
    static func show(title: String, message: String? = nil, completion: ((Bool)-> Void)? = nil) {
        let x = UIAlertController(title: title, message: message, preferredStyle: .alert)
        x.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            completion?(true)
        }))
        x.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completion?(false)
        }))
        UIApplication.getTopViewController()?.present(x, animated: true)
    }
    
}

