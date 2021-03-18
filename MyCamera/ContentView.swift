//
//  ContentView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage(UserdefaultManager.shared._hasShownOnboarding) private var hasShownOnboarding: Bool = UserdefaultManager.shared.hasShownOnboarding
    @AppStorage(UserdefaultManager.shared._doneSetup) private var doneSetup: Bool = UserdefaultManager.shared.doneSetup
    
    var body: some View {
        if hasShownOnboarding {
            if doneSetup {
                CameraView()
            } else {
                NavigationView {
                    SetupView().navigationBarHidden(true)
                }
            }
        }else {
            NavigationView {
                OnboardingView().navigationBarHidden(true)
            }
        }
    }
}
