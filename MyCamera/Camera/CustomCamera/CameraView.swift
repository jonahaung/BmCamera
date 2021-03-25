//
//  CameraControlView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 16/12/20.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
   

    @StateObject private var manager = CameraManager()
    @State private var isPotrait = Utils.isPotrait()
    @AppStorage(UserdefaultManager.shared._flashMode) private var flashMode: Int = UserdefaultManager.shared.flashMode.rawValue
    @State private var selectedPhoto: Photo?
    
    @AppStorage(UserdefaultManager.shared._offShutterSound) private var offShutterSound: Bool = UserdefaultManager.shared.offShutterSound
    
    var body: some View {
        ZStack {
            Color.black
            CameraViewControllerRepresentable(observer: manager)
            controlView
        }
        .accentColor(.white)
        .edgesIgnoringSafeArea(isPotrait ? .vertical : .all)
        .onAppear(perform: manager.willAppear)
        .onDisappear(perform: manager.willDisappear)
        .onRotate { _ in
            if manager.isSessionRunning {
                self.isPotrait = Utils.isPotrait()
            }
        }
        .sheet(item: $selectedPhoto) { photo in
            ImageViewerView(photo: photo)
        }
    }
    
}



// Control Views
extension CameraView {
    
    private var controlView: some View {
        return Group {
            if isPotrait {
                VStack {
                    topBar
                    Spacer()
                    if manager.showControls {
                        cameraControls
                        Spacer()
                    }
                    captureModeBar
                    bottomBar
                }
            }else {
                HStack {
                    leftBar
                    VStack{
                        if manager.showControls {
                            cameraControls
                        }
                        Spacer()
                        captureModeBar
                    }
                    rightBar
                }
            }
        }
    }
}



// Bars

extension CameraView {
    
    // Controls
    private var cameraControls: some View {
        return VStack {
            
            Section(header: Text("Camera Controls").foregroundColor(.white).padding(.bottom)) {
                
                Toggle(isOn: $offShutterSound) {
                    Text("Mute Shutter Sound")
                }
                Divider()
                HStack {
                    Text("Flash Mode").padding(.trailing)
                    Spacer()
                    Picker(selection: $flashMode, label: EmptyView()) {
                        Text("Off").tag(AVCaptureDevice.FlashMode.off.rawValue)
                        Text("On").tag(AVCaptureDevice.FlashMode.on.rawValue)
                        Text("Auto").tag(AVCaptureDevice.FlashMode.auto.rawValue)
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
            Divider()
            Section(header: Text("Photo Quality")) {
                Picker(selection: $manager.photoQualityPrioritizationModeIndex, label: EmptyView()) {
                    Text("Speed").tag(AVCapturePhotoOutput.QualityPrioritization.speed)
                    Text("Balanced").tag(AVCapturePhotoOutput.QualityPrioritization.balanced)
                    Text("Quality").tag(AVCapturePhotoOutput.QualityPrioritization.quality)
                }.pickerStyle(SegmentedPickerStyle())
                Divider()
                HStack {
                    Text("Zoom").padding(.trailing)
                    Spacer()
                    Slider(value: $manager.zoom, in: 0...20)
                }

            }
        }
        .foregroundColor(Color(.lightText))
        .padding()
        .background(Blur(style: .systemMaterialDark))
        .cornerRadius(20)
        .padding()
        
    }
    // Top Bar
    private func getTopBarItems() -> some View {
        return Group {
            flashModeButton
            cameraControl
            Spacer()
            if manager.isRecordingVideo {
                Text(Date().addingTimeInterval(TimeInterval(manager.movieTime)), style: .timer).bold().foregroundColor(.yellow)
                Spacer()
            }
            settingButton

        }
    }
    
    private var topBar: some View {
        return HStack {
            getTopBarItems()
        }
        .padding(.horizontal)
        .padding(.top, 50)
        .background(Blur(style: .systemChromeMaterialDark))
    }
    
    private var leftBar: some View {
        return VStack {
            getTopBarItems()
        }
        .padding(.horizontal)
        .padding(.leading, 20)
        .background(Blur(style: .systemChromeMaterialDark))
    }
    
    
    // Bottom Bar
    
    private func getBottomBarItems() -> some View {
        return Group {
            Spacer()
            photoLibararyButton
            Spacer()
            captureButton
            Spacer()
            changeCameraButton
            Spacer()
        }
    }
    
    private var bottomBar: some View {
        return HStack(alignment: .bottom) {
            getBottomBarItems()
        }
        .padding(.top)
        .padding(.bottom, 40)
        .background(Blur(style: .systemChromeMaterialDark))
    }
    
    private var rightBar: some View {
        return VStack() {
            getBottomBarItems()
        }
        .padding(.horizontal)
        .padding(.trailing, 30)
        .background((Blur(style: .systemChromeMaterialDark)))
    }
    
    // Bottom Bar II
    private var captureModeBar: some View {
        return HStack(alignment: .bottom) {
            thumbnilButton()
            Spacer()
            captureModeButton
                .disabled(!manager.captureModeControlEnabled)
        }.padding(.horizontal)
    }
    
}


// Buttons

extension CameraView {
    
    // Capture
    private var captureButton: some View {
        return Button {
            if manager.captureMode == .photo {
                manager.capturePhoto()
            } else {
                manager.toggleMovieRecording()
            }
            
        } label: {
            let accentColor = manager.isRecordingVideo ? Color(.systemRed).opacity(0.8) : Color.white
            let imageName = manager.captureMode == .photo ? "circle.fill" : "largecircle.fill.circle"
            Image(systemName: imageName)
                .font(.system(size: 65, weight: .ultraLight))
                .shadow(radius: 5)
                .zIndex(2)
                .accentColor(accentColor)
                
            
        }.disabled(!manager.captureButtonEnabled)
    }
    
    // Capture Mode
    private var captureModeButton: some View {
        return Picker("Please choose a color", selection: $manager.captureMode) {
            ForEach(CaptureMode.allCases, id: \.self) {
                Image(systemName: $0.imageName)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .disabled(!manager.captureButtonEnabled)
        .frame(maxWidth: 100, maxHeight: 50)
        
    }


    // Camera Control
    private var cameraControl: some View {
        return Button {
            withAnimation{
                manager.showControls.toggle()
            }
            
        } label: {
            Image(systemName: "slider.horizontal.below.rectangle").padding()
        }
    }
    // Flash
    private var flashModeButton: some View {
        return Button {
            var mode = AVCaptureDevice.FlashMode(rawValue: flashMode) ?? .off
            switch mode {
            case .off:
                mode = .on
            case .on:
                mode = .auto
            case .auto:
                mode = .off
            @unknown default:
                break
            }
            flashMode = AVCaptureDevice.FlashMode(rawValue: mode.rawValue)!.rawValue
            
        } label: {
            Image(systemName: AVCaptureDevice.FlashMode(rawValue: flashMode)?.imageName ?? "").padding()
        }
    }
    // CameraMode
    private var changeCameraButton: some View {
        return Button {
            
            manager.changeCamera()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .padding()
                
        }
        .disabled(!manager.captureButtonEnabled)
        
    }
    
    // Album
    private var photoLibararyButton: some View {
        return NavigationLink(destination: ImageGalleryView()) {
            Group{
                if manager.photos.count > 0 {
                    Image(systemName: "\(manager.photos.count).circle.fill").padding()
                } else {
                    Image(systemName: "photo.on.rectangle.angled").padding()
                        
                }
            }
            
            
        }
        
    }
    
    // Settings
    private var settingButton: some View {
        return NavigationLink(destination: SettingsView()) {
            Image(systemName: "ellipsis").padding()
        }
    }

    // Thumbnil
    
    private func thumbnilButton() -> some View {
        return Group {
            if let photo = manager.photos.last, let image = photo.thumbnil {
                Button {
                    selectedPhoto = photo
                } label: {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 100)
                        .cornerRadius(8)
                }
                
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
