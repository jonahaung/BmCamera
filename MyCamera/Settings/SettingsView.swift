//
//  SettingsView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 17/3/21.
//

import SwiftUI
private enum PresentViewType: Identifiable {
    var id: PresentViewType { return self }
    case lockScreenView, imageGalleryView
}


struct SettingsView: View {
    
    @AppStorage(UserdefaultManager.shared._hasShownOnboarding) private var hasShownOnboarding: Bool = UserdefaultManager.shared.hasShownOnboarding
    @StateObject var currentLoginSession = CurrentLoginSession()
    @Environment(\.presentationMode) var presentationMode
    @State private var presentViewType: PresentViewType?
    
    var body: some View {
        
        Form {
            Section(header: Text("Albums and Passcodes").foregroundColor(Color(.tertiaryLabel))) {
    
                Button(action: {
                    UserdefaultManager.shared.doneSetup = false
                }) {
                    SettingCell(text: "Create New Album", subtitle: nil, imageName: "lock.shield", color: .blue)
                }
                Button(action: {
                    presentViewType = .lockScreenView
                }) {
                    SettingCell(text: "Update Current Album", subtitle: nil, imageName: "lock.square.stack", color: .red)
                }
                Button(action: {
                    presentViewType = .imageGalleryView
                }) {
                    SettingCell(text: "View Existing Album", subtitle: nil, imageName: "photo", color: .orange)
                }
            }
            
            Section(header: Text("App Settings").foregroundColor(Color(.tertiaryLabel))) {
                Button(action: {
                    UserdefaultManager.shared.hasShownOnboarding = false
                }) {
                    SettingCell(text: "Show Onboarding", subtitle: nil, imageName: "applescript", color: .green)
                }
                Button(action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }) {
                    SettingCell(text: "Open Device Settings", subtitle: nil, imageName: "iphone", color: .pink)
                }
            }
            Section(header: Text("App Informations").foregroundColor(Color(.tertiaryLabel))) {
            
                SettingCell(text: "App Version", subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, imageName: "app.badge", color: .green)
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
        
            Section(header: Text("Contacts").foregroundColor(Color(.tertiaryLabel))) {
            
                Button(action: {
                    SettingManager.shared.gotoPrivacyPolicy()
                }) {
                    SettingCell(text: "Privacy Policy", subtitle: nil, imageName: "doc.plaintext.fill", color: .blue)
                }
                
                Button(action: {
                    SettingManager.shared.gotoContactUs()
                }) {
                    SettingCell(text: "Contact Us", subtitle: nil, imageName: "mail.fill", color: .purple)
                }

            }
           
        }
        .foregroundColor(Color.primary)
        .navigationTitle("Settings")
        .navigationBarItems(trailing: Button("Done", action: {
            presentationMode.wrappedValue.dismiss()
        }))
        .sheet(item: $presentViewType) { type in
            switch type {
            case PresentViewType.lockScreenView:
                LockScreenView().environmentObject(currentLoginSession)
            case .imageGalleryView:
                ImageGalleryView()
                    .environmentObject(currentLoginSession)
            }
        }
    }
}
