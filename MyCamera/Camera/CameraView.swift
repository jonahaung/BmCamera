//
//  CameraControlView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 16/12/20.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    
    @StateObject private var currentLoginSession = CurrentLoginSession()
    @StateObject private var manager = CameraManager()
    @State private var isPotrait = Utils.isPotrait()
    @State private var showMenuSheet = false
    @AppStorage(UserdefaultManager.shared._flashMode) private var flashMode: Int = UserdefaultManager.shared.flashMode.rawValue
    enum PresentingViewType: Identifiable {
        var id: PresentingViewType { return self }
        case photoLibrary, lockScreen, settings, imageViewer
    }
    @State private var presentingViewType: PresentingViewType?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            CameraViewControllerRepresentable(observer: manager)
                .edgesIgnoringSafeArea(.all)
            controlView
                
                .zIndex(2)
        }
        
        .onAppear(perform: manager.willAppear)
        .onDisappear(perform: manager.willDisappear)
        .onRotate { _ in
            self.isPotrait = Utils.isPotrait()
        }
        .fullScreenCover(item: $presentingViewType) { mode in
            getFullScreenCoverView(for: mode)
                .environmentObject(currentLoginSession)
                .onAppear{
                    manager.willDisappear()
                }
                .onDisappear{
                    manager.resumeInterruptedSession()
                    currentLoginSession.reset()
            }
        }
        .actionSheet(isPresented: $showMenuSheet, content: menuActionSheet)
    }
}


// Full Screen Cover

extension CameraView {
    private func getFullScreenCoverView(for presentingViewType: PresentingViewType) -> some View {
        return Group {
            switch presentingViewType {
            case PresentingViewType.photoLibrary:
                ImageGalleryView()
            case .lockScreen:
                LockScreenView()
            case .settings:
                NavigationView {
                    SettingsView()
                }
            case .imageViewer:
                if let photo = manager.currentCapturedPhoto {
                    ImageViewerView(photo: photo)
                }
                
            }
        }
    }
}


// SubViews
extension CameraView {

    private var controlView: some View {
        return Group {
            if isPotrait {
                VStack {
                    topBar
                    Spacer()
    
                    captureModeBar
                    potraitBottomBar
                }
            }else {
                HStack {
                    VStack{
                        topBar
                        Spacer()
                    }
                    Spacer()
            
                    VStack {
                        captureModeBar
                        Spacer()
                    }
                    landScapeBottomBar
                }
            }
        }
        .padding()
    }
}

// Bars

extension CameraView {
    // Top Bar
    private var topBar: some View {
        return VStack {
            HStack {
                Button {
                    manager.photoQualityPrioritizationModeIndex = manager.photoQualityPrioritizationModeIndex.toggle()
                } label: {
                    Text(manager.photoQualityPrioritizationModeIndex.description).font(.callout)
                }
                Spacer()
                menuButton
            }
            HStack {
                if manager.isRecordingVideo {
                    Text(Date().addingTimeInterval(TimeInterval(manager.movieTime)), style: .timer)
                }
            }
        }
    }
    
    // Bottom Bar II
    private var captureModeBar: some View {
        return HStack {
            if manager.showZoomControl {
                Slider(value: $manager.zoom, in: 0...20) {
                }
            }
            if let photo = manager.currentCapturedPhoto {
                thumbnilButton(photo: photo)
            }
            Spacer()
            captureModeButton
            .disabled(!manager.captureModeControlEnabled)
        }
    }

    // Bottom Bar
    private var potraitBottomBar: some View {
        return HStack(alignment: .bottom) {
            zoomButton
            Spacer()
            flashModeButton
            Spacer()
            captureButton
            Spacer()
            changeCameraButton
            Spacer()
            photoLibararyButton
            
        }.font(.title3)
    }
    private var landScapeBottomBar: some View {
        return VStack(alignment: .trailing) {
            zoomButton
            Spacer()
            flashModeButton
            Spacer()
            captureButton
            Spacer()
            changeCameraButton
            Spacer()
            photoLibararyButton
            
        }.font(.title3)
    }
}



// Action Sheet

extension CameraView {
    // Menu
    private func menuActionSheet() -> ActionSheet {
        return ActionSheet(
            title: Text(String()),
            message: Text(String()),
            buttons: [
                .default(Text("Open Current Album"), action: {
                    presentingViewType = .photoLibrary
                }),
                .default(Text("Update Current Album"), action: {
                    presentingViewType = .lockScreen
                }),
                .default(Text("Open Settings"), action: {
                    presentingViewType = .settings
                }),
                .cancel()
            ]
        )
    }
}

// Buttons

extension CameraView {
    
    // Capture
    private var captureButton: some View {
        return Button {
            let isPhoto = manager.captureMode == CaptureMode.photo
            if isPhoto {
                manager.capturePhoto()
            } else {
                manager.toggleMovieRecording()
            }

        } label: {
            let isPhoto = manager.captureMode == CaptureMode.photo
            let accentColor = manager.isRecordingVideo ? Color(.systemRed) : Color.white
            let imageName = isPhoto ? "circle.fill" : manager.isRecordingVideo ? "smallcircle.fill.circle" : "largecircle.fill.circle"
            Image(systemName: imageName)
                .font(.system(size: 72, weight: .thin))
                .accentColor(accentColor)
            
        }.disabled(!manager.captureButtonEnabled)
    }
    // Zoom
    private var zoomButton: some View {
        return Button {
            withAnimation{
                manager.showZoomControl.toggle()
            }
        } label: {
            Image(systemName: "magnifyingglass").padding()
        }
    }
    
    // Flash
    private var flashModeButton: some View {
        return Button {
            var mode = AVCaptureDevice.FlashMode(rawValue: self.flashMode) ?? .off
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
            UserdefaultManager.shared.flashMode = mode
        } label: {
            Image(systemName: AVCaptureDevice.FlashMode(rawValue: flashMode)?.imageName ?? "").padding()
        }
    }
    // CameraMode
    private var changeCameraButton: some View {
        return Button {
            
            manager.changeCamera()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath").padding()
        }.disabled(!manager.captureButtonEnabled)
    }
    // Album
    private var photoLibararyButton: some View {
        return Button {
            presentingViewType = .photoLibrary
        } label: {
            Image(systemName: "photo.on.rectangle.angled").padding()
        }
    }
    
    // Menu
    private var menuButton: some View {
        return Button {
            showMenuSheet = true
        } label: {
            Image(systemName: "ellipsis").padding()
        }
    }
    
    // Capture Mode
    private var captureModeButton: some View {
        return Button {
            manager.captureMode = manager.captureMode.toggle()
        } label: {
            Image(systemName: manager.captureMode.imageName).padding().font(.title3)
        }
        .disabled(!manager.captureButtonEnabled)
    }

    
    // Thumbnil
    
    private func thumbnilButton(photo: Photo) -> some View {
        return Button {
            presentingViewType = .imageViewer
        } label: {
            if let image = photo.thumbnil() {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 80, height: 80).cornerRadius(40)
            }
        }

    }
}
