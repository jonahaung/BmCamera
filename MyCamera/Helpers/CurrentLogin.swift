//
//  CurrentLogin.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import UIKit

class CurrentLoginSession: ObservableObject {
    
    @Published var isLoggingIn = false
    @Published var folderName: String?
    
    func reset() {
        folderName = nil
        isLoggingIn = false
    }
}
