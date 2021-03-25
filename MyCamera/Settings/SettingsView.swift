//
//  SettingsView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 17/3/21.
//

import SwiftUI
import AVFoundation

private enum PresentViewType: Identifiable {
    var id: PresentViewType { return self }
    case eulaView
}


struct SettingsView: View {
    
   
    @AppStorage(UserdefaultManager.shared._hasShownOnboarding) private var hasShownOnboarding: Bool = UserdefaultManager.shared.hasShownOnboarding
    @State private var presentViewType: PresentViewType?
    @AppStorage(UserdefaultManager.shared._offShutterSound) private var offShutterSound: Bool = UserdefaultManager.shared.offShutterSound
    @AppStorage(UserdefaultManager.shared._flashMode) private var flashMode: Int = UserdefaultManager.shared.flashMode.rawValue
    
    var body: some View {
        
        Form {
            Section(header: Text("Albums and Passcodes").foregroundColor(Color(.tertiaryLabel))) {
                
                NavigationLink(destination: LockScreenView(lockScreenType: .newAlbum, completion: nil)) {
                    SettingCell(text: "Create New Album", subtitle: nil, imageName: "plus.circle.fill", color: .yellow)
                }
                
                NavigationLink(destination: LockScreenView(lockScreenType: .updateCurrentAlbum, completion: nil)) {
                    SettingCell(text: "Update Current Album", subtitle: nil, imageName: "mappin.circle.fill", color: .green)
                }
                
                NavigationLink(destination: ImageGalleryView()) {
                    SettingCell(text: "View Existing Album", subtitle: nil, imageName: "eye.circle.fill", color: .purple)
                }
                
                Button(action: {
                    PersistenceController.shared.deleteAll()
                }) {
                    SettingCell(text: "Clear All Albums", subtitle: nil, imageName: "trash.circle.fill", color: .red)
                }
            }
            
            Section(header: Text("Camera Controls").foregroundColor(Color(.tertiaryLabel))) {
                Toggle(isOn: $offShutterSound) {
                    Text("Mute Photo Capture Sound")
                }
                
                HStack {
                    Text("Flash Mode")
                    Spacer()
                    Picker(selection: $flashMode, label: EmptyView()) {
                        Text("Off").tag(AVCaptureDevice.FlashMode.off.rawValue)
                        Text("On").tag(AVCaptureDevice.FlashMode.on.rawValue)
                        Text("Auto").tag(AVCaptureDevice.FlashMode.auto.rawValue)
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
        
            
            Section(header: Text("App Settings").foregroundColor(Color(.tertiaryLabel))) {
                Button(action: {
                    UserdefaultManager.shared.hasShownOnboarding = false
                }) {
                    SettingCell(text: "Show Onboarding", subtitle: nil, imageName: "house.fill", color: .green)
                }
                Button(action: {
                    presentViewType = .eulaView
                }) {
                    SettingCell(text: "End User License Agreement", subtitle: nil, imageName: "shield.fill", color: .orange)
                }
                Button(action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }) {
                    SettingCell(text: "Open Device Settings", subtitle: nil, imageName: "gearshape.fill", color: .pink)
                }
            }
            
            Section(header: Text("App Informations").foregroundColor(Color(.tertiaryLabel))) {
            
                SettingCell(text: "App Version", subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, imageName: "app.badge.fill", color: .green)
                    .foregroundColor(.secondary)
                Button(action: {
                    SettingManager.shared.shareApp()
                }) {
                    SettingCell(text: "Share App", subtitle: nil, imageName: "arrowshape.turn.up.right.fill", color: .pink)
                }
                Button(action: {
                    SettingManager.shared.rateApp()
                }) {
                    SettingCell(text: "Rate App", subtitle: nil, imageName: "star.fill", color: Color(.systemIndigo))
                }
            }
        
            Section(header: Text("Contacts").foregroundColor(Color(.tertiaryLabel)), footer: Text("Aung Ko Min (iOS Developer)\nSingapore\n+65 88585229\njonahaung@gmail.com").foregroundColor(.secondary).padding()) {
            
                Button(action: {
                    SettingManager.shared.gotoPrivacyPolicy()
                }) {
                    SettingCell(text: "Privacy Policy", subtitle: nil, imageName: "lock.shield.fill", color: .blue)
                }
                
                Button(action: {
                    SettingManager.shared.gotoContactUs()
                }) {
                    SettingCell(text: "Contact Us", subtitle: nil, imageName: "phone.circle.fill", color: .purple)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(item: $presentViewType) { type in
            switch type {
            case .eulaView:
                EULAView()
            }
        }
    }
}
