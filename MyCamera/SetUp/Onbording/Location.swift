//
//  Location.swift
//  Food
//
//  Created by BqNqNNN on 7/12/20.
//

import SwiftUI
import AVKit

struct Location: View {
    
    var body: some View {
        VStack {
            Spacer()
            Image("welcome")
                .resizable()
                .scaledToFit()
            Text("Hi, nice to meet you !")
                .font(.title)
                .bold()
            Text("Choose your location to find \nrestraurants around you. ")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                .padding(.all, 20)
            
            Spacer()
            Button {
                requestAccess()
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                        
                    
                    Text("Allow Camera Usage")
                        .bold()
                        
                    Image(systemName: "mic.fill")
                        
                    
                }
                .foregroundColor(.accentColor)
                .frame(width: 300, height: 60)
                .border(Color.accentColor, width: 3)
                .cornerRadius(5)
            }
            
            Button {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            } label: {
                Text("Select Manually")
                    .bold()
                    .underline()
                    .foregroundColor(.gray)
                    .padding()
            }
            Spacer()
        }
    }
    
    private func requestAccess() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            UserdefaultManager.shared.hasShownOnboarding = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted {
                    AVCaptureDevice.requestAccess(for: .audio, completionHandler: { granted in
                        if granted {
                            UserdefaultManager.shared.hasShownOnboarding = true
                        }
                    })
                }
            })
            
        default:
           break
        }
    }
}
