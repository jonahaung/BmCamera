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
    case eulaView, lockScreenCreateNewAlbum, lockScreenUpdateCurrentAlbum, lockScreenViewExistingAlbum, onboardingView
}


struct SettingsView: View {
    
   
    @AppStorage(UserdefaultManager.shared._hasShownOnboarding) private var hasShownOnboarding: Bool = UserdefaultManager.shared.hasShownOnboarding
    @State private var presentViewType: PresentViewType?
    @AppStorage(UserdefaultManager.shared._offShutterSound) private var offShutterSound: Bool = UserdefaultManager.shared.offShutterSound
    @AppStorage(UserdefaultManager.shared._flashMode) private var flashMode: Int = UserdefaultManager.shared.flashMode.rawValue
    @AppStorage(UserdefaultManager.shared._fontDesign) private var fontDesignIndex: Int = UserdefaultManager.shared.fontDesign.rawValue
    @AppStorage(UserdefaultManager.shared._photoQualityPrioritizationMode) private var photoQualityPrioritizationModeIndex: Int = UserdefaultManager.shared.photoQualityPrioritizationMode.rawValue
    
    var body: some View {
        
        Form {
            
            Section(header: Text("Albums and Passcodes").foregroundColor(Color(.tertiaryLabel))) {
                Button("Create New Album") { presentViewType = .lockScreenCreateNewAlbum }
                Button("Update Current Album") { presentViewType = .lockScreenUpdateCurrentAlbum }
                Button("View Existing Album") { presentViewType = .lockScreenViewExistingAlbum }
                Button("Clear All Albums") { PersistenceController.shared.deleteAll() }
            }
            
            Section(header: Text("Camera Controls").foregroundColor(Color(.tertiaryLabel))) {
                
                Picker(selection: $offShutterSound, label: Text("Shutter Sound")) {
                    Text("On").tag(false)
                    Text("Off").tag(true)
                }
                
                Picker(selection: $flashMode, label: Text("Flash Mode")) {
                    Text(AVCaptureDevice.FlashMode.off.description).tag(AVCaptureDevice.FlashMode.off.rawValue)
                    Text(AVCaptureDevice.FlashMode.on.description).tag(AVCaptureDevice.FlashMode.on.rawValue)
                    Text(AVCaptureDevice.FlashMode.auto.description).tag(AVCaptureDevice.FlashMode.auto.rawValue)
                }
                
                Picker(selection: $photoQualityPrioritizationModeIndex, label: Text("Photo Quality")) {
                    Text(AVCapturePhotoOutput.QualityPrioritization.speed.description).tag(AVCapturePhotoOutput.QualityPrioritization.speed.rawValue)
                    Text(AVCapturePhotoOutput.QualityPrioritization.balanced.description).tag(AVCapturePhotoOutput.QualityPrioritization.balanced.rawValue)
                    Text(AVCapturePhotoOutput.QualityPrioritization.quality.description).tag(AVCapturePhotoOutput.QualityPrioritization.quality.rawValue)
                }
            }
        
            Section(header: Text("Device Settings").foregroundColor(Color(.tertiaryLabel))) {
                
                Picker(selection: $fontDesignIndex, label: Text("Font Design")) {
                    Text(FontDesign.rounded.name).tag(FontDesign.rounded.rawValue)
                    Text(FontDesign.monoSpaced.name).tag(FontDesign.monoSpaced.rawValue)
                    Text(FontDesign.serif.name).tag(FontDesign.serif.rawValue)
                }
                
                Button(action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }) {
                    Text("Open Device Settings")
                }
            }
            
            
            Section(header: Text("App Settings").foregroundColor(Color(.tertiaryLabel))) {
                SettingCell(text: "App Version", subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, imageName: "app.badge.fill", color: .purple)
                    .foregroundColor(.secondary)
                Button(action: {
                    presentViewType = .onboardingView
                }) {
                    SettingCell(text: "About the App", subtitle: nil, imageName: "house.fill", color: .green)
                }
                Button(action: {
                    presentViewType = .eulaView
                }) {
                    SettingCell(text: "User License Agreement", subtitle: nil, imageName: "shield.fill", color: .orange)
                }
                Button(action: {
                    SettingManager.shared.gotoPrivacyPolicy()
                }) {
                    SettingCell(text: "Privacy Policy Website", subtitle: nil, imageName: "lock.shield.fill", color: .blue)
                }
                
            }
            
            Section(header: Text("App Informations").foregroundColor(Color(.tertiaryLabel))) {
        
                Button(action: {
                    SettingManager.shared.shareApp()
                }) {
                    SettingCell(text: "Share App", subtitle: nil, imageName: "arrowshape.turn.up.right.fill", color: .pink)
                }
                Button(action: {
                    SettingManager.shared.rateApp()
                }) {
                    SettingCell(text: "Rate on AppStore", subtitle: nil, imageName: "star.fill", color: Color(.systemIndigo))
                }
            }
        
            Section(header: Text("Contacts").foregroundColor(Color(.tertiaryLabel)), footer: Text("Aung Ko Min (iOS Developer)\nSingapore\n+65 88585229\njonahaung@gmail.com").foregroundColor(.secondary).padding()) {
                Button(action: {
                    SettingManager.shared.gotoContactUs()
                }) {
                    SettingCell(text: "Contact Us", subtitle: nil, imageName: "phone.circle.fill", color: .purple)
                }
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .navigationTitle("Settings")
        .sheet(item: $presentViewType) { type in
            switch type {
            case .eulaView:
                EULAView(showAgreementButton: false)
            case .lockScreenCreateNewAlbum:
                LockScreenView(lockScreenType: .newAlbum, completion: nil)
            case .lockScreenUpdateCurrentAlbum:
                LockScreenView(lockScreenType: .updateCurrentAlbum, completion: nil)
            case .lockScreenViewExistingAlbum:
                ImageGalleryView()
            case .onboardingView:
                OnboardingView(isFirstTime: false)
            }
        }
    }
}
