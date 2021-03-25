//
//  MyCameraApp.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import SwiftUI

@main
struct MyCameraApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
            .font(.system(size: UIFont.buttonFontSize))
            
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        
        return true
    }
    
    

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return Utils.orientationLock
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        PersistenceController.shared.save()
    }
}
