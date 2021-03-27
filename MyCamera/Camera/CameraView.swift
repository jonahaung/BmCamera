//
//  CameraControlView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 16/12/20.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    
    enum ActionSheetType: Identifiable {
        var id: ActionSheetType { return self }
        case lockScreen
    }
    enum SheetType: Identifiable {
        var id: SheetType { return self }
        case imageViewer, updateCurrentAlbum
    }
    
    @State private var actionSheetType: ActionSheetType?
    @State private var sheetType: SheetType?
    @State var currentZoomFactor: CGFloat = 1.0
    @StateObject private var manager = CameraManager()
    @State private var isPotrait = Utils.isPotrait()
    
    @AppStorage(UserdefaultManager.shared._flashMode) private var flashMode: Int = UserdefaultManager.shared.flashMode.rawValue
    @AppStorage(UserdefaultManager.shared._offShutterSound) private var offShutterSound: Bool = UserdefaultManager.shared.offShutterSound
    @AppStorage(UserdefaultManager.shared._photoQualityPrioritizationMode) private var photoQualityPrioritizationModeIndex: Int = UserdefaultManager.shared.photoQualityPrioritizationMode.rawValue
    
    var body: some View {
        GeometryReader { reader in
            Color(.darkText).edgesIgnoringSafeArea(.all)
            ZStack {
               
                CameraViewControllerRepresentable(manager: manager)
                    .gesture( dragGesture(reader: reader) )
                controlView
            }
            
            .accentColor(Color(.opaqueSeparator))
//            .edgesIgnoringSafeArea(isPotrait ? .vertical : .all)
            .onAppear(perform: manager.willAppear)
            .onDisappear(perform: manager.willDisappear)
            .onRotate { _ in
                if manager.isSessionRunning {
                    self.isPotrait = Utils.isPotrait()
                }
            }
            .actionSheet(item: $actionSheetType, content: { type in
                switch type {
                case .lockScreen:
                    return LockActionSheet()
                }
            })
            
            .sheet(item: $sheetType) { type in
                switch type {
                case .imageViewer:
                    if let photo = manager.photos.last {
                        ImageViewerView(photo: photo)
                    }
                    
                case .updateCurrentAlbum:
                    LockScreenView(lockScreenType: .updateCurrentAlbum, completion: nil).onDisappear{
                        self.manager.alertError = AlertError(title: "Current album is updated to passcode - \(UserdefaultManager.shared.currentFolderName ?? "nil")", message: "All photos and videos captured by this camera will be saved into this album", primaryButtonTitle: "OK")
                    }
                }
            }
            .alert(item: $manager.alertError, content: { alertError in
                Alert(title: Text(alertError.title), message: Text(alertError.message), dismissButton: .default(Text(alertError.primaryButtonTitle), action: {
                    alertError.primaryAction?()
                }))
            })
        }
        
    }
    
}

// Drag
extension CameraView {
    
    private func LockActionSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Your Current Album passcode is - \(UserdefaultManager.shared.currentFolderName ?? "")"),
            message: Text("All photos and videos captured by this camera will be saved into this album"),
            buttons: [
                .default(Text("Switch to another album"), action: {
                    sheetType = .updateCurrentAlbum
                }),
                .cancel()
            ]
        )
    }
    private func dragGesture(reader: GeometryProxy) -> some Gesture {
        return DragGesture().onChanged({ val in
            //  Only accept vertical drag
            if abs(val.translation.height) > abs(val.translation.width) {
                
                let percentage: CGFloat = -(val.translation.height / reader.size.height)
                
                let calc = currentZoomFactor + percentage
                //  Limit zoom factor to a maximum of 5x and a minimum of 1x
                let zoomFactor: CGFloat = min(max(calc, 1), 5)
                //  Store the newly calculated zoom factor
                currentZoomFactor = zoomFactor
                //  Sets the zoom factor to the capture device session
                manager.set(zoom: zoomFactor)
            }
        })
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
                        Text(AVCaptureDevice.FlashMode.off.description).tag(AVCaptureDevice.FlashMode.off.rawValue)
                        Text(AVCaptureDevice.FlashMode.on.description).tag(AVCaptureDevice.FlashMode.on.rawValue)
                        Text(AVCaptureDevice.FlashMode.auto.description).tag(AVCaptureDevice.FlashMode.auto.rawValue)
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
            Divider()
            Section(header: Text("Photo Quality")) {
                Picker(selection: $photoQualityPrioritizationModeIndex, label: Text("Photo Quality")) {
                    Text(AVCapturePhotoOutput.QualityPrioritization.speed.description).tag(AVCapturePhotoOutput.QualityPrioritization.speed.rawValue)
                    Text(AVCapturePhotoOutput.QualityPrioritization.balanced.description).tag(AVCapturePhotoOutput.QualityPrioritization.balanced.rawValue)
                    Text(AVCapturePhotoOutput.QualityPrioritization.quality.description).tag(AVCapturePhotoOutput.QualityPrioritization.quality.rawValue)
                }.pickerStyle(SegmentedPickerStyle())
                Divider()
                HStack {
                    
                    Slider(value: $currentZoomFactor, in: 0...5, step: 0.2, onEditingChanged: { _ in
                        manager.set(zoom: currentZoomFactor)
                    }, minimumValueLabel: Text("\(Int(currentZoomFactor))"), maximumValueLabel: Text("5")) {
                        EmptyView()
                    }
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
            cameraControlButton
            flashModeButton
            Spacer()
            if manager.isRecordingVideo {
                Text(Date().addingTimeInterval(TimeInterval(manager.movieTime)), style: .timer).foregroundColor(.yellow)
                Spacer()
            }
            lockButton
            settingButton
            
        }
    }
    
    private var topBar: some View {
        return HStack {
            getTopBarItems()
        }.padding(.horizontal)
//        .padding()
//        .padding(.horizontal)
//        .padding(.top, 50)
        .background(Color.black)
    }
    
    private var leftBar: some View {
        return VStack {
            getTopBarItems()
        }.padding(.vertical)
//        .padding()
        .background(Color.black)
//        .padding(.horizontal)
//        .padding(.leading, 20)
//        .background(Blur(style: .systemChromeMaterialDark))
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
        .padding()
        .background(Color.black)
//        .padding(.top)
//        .padding(.bottom, 40)
//        .background(Color(.darkText))
    }
    
    private var rightBar: some View {
        return VStack() {
            getBottomBarItems()
        }
        .padding()
        .background(Color.black)
//        .padding(.horizontal)
//        .padding(.trailing, 30)
//        .background((Blur(style: .systemChromeMaterialDark)))
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
    
    // Lock
    private var lockButton: some View {
        return Button {
            actionSheetType = .lockScreen
        } label: {
            Image(systemName: "lock.open")
        }
    }
    
    // Camera Control
    private var cameraControlButton: some View {
        return Button {
            withAnimation{
                manager.showControls.toggle()
            }
            
        } label: {
            Image(systemName: "slider.horizontal.below.rectangle")
        }
    }
    // Flash
    private var flashModeButton: some View {
        return Button {
            var mode = AVCaptureDevice.FlashMode(rawValue: flashMode) ?? .off
            switch mode {
            case .off:
                mode = AVCaptureDevice.FlashMode.on
            case .on:
                mode =  AVCaptureDevice.FlashMode.auto
            case .auto:
                mode =  AVCaptureDevice.FlashMode.off
            @unknown default:
                mode =  AVCaptureDevice.FlashMode.on
            }
            flashMode = mode.rawValue
            manager.objectWillChange.send()
        } label: {
            Text((AVCaptureDevice.FlashMode(rawValue: flashMode) ?? .off).description).font(.callout)
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
            Image(systemName: "info").padding()
        }
    }
    
    // Thumbnil
    
    private func thumbnilButton() -> some View {
        return Group {
            if let photo = manager.photos.last, let image = photo.thumbnil {
                Button {
                    sheetType = .imageViewer
                } label: {
                    
                    Image(uiImage:image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .animation(.spring())
                    
                    
                }
            }
        }
    }
}
