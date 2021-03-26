//
//  MyCameraApp.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import SwiftUI

@main
struct MyCameraApp: App {
    
    @AppStorage(UserdefaultManager.shared._hasShownOnboarding) private var hasShownOnboarding: Bool = UserdefaultManager.shared.hasShownOnboarding
    @AppStorage(UserdefaultManager.shared._doneSetup) private var doneSetup: Bool = UserdefaultManager.shared.doneSetup
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if hasShownOnboarding {
                    if doneSetup {
                        CameraView()
                            .navigationBarHidden(true)
                            
                    } else {
                        LockScreenView(lockScreenType: .appSetUp) { folderName in
                            print(folderName)
                        }
                    }
                }else {
                    OnboardingView()
                }
            }
            
            .font(.system(size: 19, weight: .regular, design: .rounded))
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
