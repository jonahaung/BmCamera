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
    @AppStorage(UserdefaultManager.shared._fontDesign) private var fontDesign: Int = UserdefaultManager.shared.fontDesign.rawValue
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
                    OnboardingView(isFirstTime: true)
                }
            }
            
            .font(.system(size: UIFontMetrics.default.scaledValue(for: 19), weight: .regular, design: FontDesign(rawValue: fontDesign)?.design ?? .default))
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
