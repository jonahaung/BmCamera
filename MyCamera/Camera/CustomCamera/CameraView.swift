//
//  CameraControlView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 16/12/20.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    
    @State var currentZoomFactor: CGFloat = 1.0
    @StateObject private var manager = CameraManager()
    @State private var isPotrait = Utils.isPotrait()
    @State private var flashMode: AVCaptureDevice.FlashMode = UserdefaultManager.shared.flashMode
    @State private var selectedPhoto: Photo?
    
    @AppStorage(UserdefaultManager.shared._offShutterSound) private var offShutterSound: Bool = UserdefaultManager.shared.offShutterSound
    
    var body: some View {
        GeometryReader { reader in
            Color(.darkText).edgesIgnoringSafeArea(.all)
            ZStack {
               
                CameraViewControllerRepresentable(manager: manager)
                    .gesture( dragGesture(reader: reader) )
                controlView
            }
            
            .accentColor(.white)
//            .edgesIgnoringSafeArea(isPotrait ? .vertical : .all)
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
            
            .alert(isPresented: $manager.showAlertError, content: {
                Alert(title: Text(manager.alertError.title), message: Text(manager.alertError.message), dismissButton: .default(Text(manager.alertError.primaryButtonTitle), action: {
                    manager.alertError.primaryAction?()
                }))
            })
        }
        
    }
    
}



// Control Views
extension CameraView {
    
    
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
                        Text("Off").tag(AVCaptureDevice.FlashMode.off)
                        Text("On").tag(AVCaptureDevice.FlashMode.on)
                        Text("Auto").tag(AVCaptureDevice.FlashMode.auto)
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
            flashModeButton
            cameraControl
            Spacer()
            if manager.isRecordingVideo {
                Text(Date().addingTimeInterval(TimeInterval(manager.movieTime)), style: .timer).foregroundColor(.yellow)
                Spacer()
            }
            settingButton
            
        }
    }
    
    private var topBar: some View {
        return HStack {
            getTopBarItems()
        }
//        .padding()
//        .padding(.horizontal)
//        .padding(.top, 50)
        .background(Color.black)
    }
    
    private var leftBar: some View {
        return VStack {
            getTopBarItems()
        }
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
            
            switch flashMode {
            case .off:
                flashMode = .on
            case .on:
                flashMode = .auto
            case .auto:
                flashMode = .off
            @unknown default:
                flashMode = .auto
            }
            
            UserdefaultManager.shared.flashMode = flashMode
            
        } label: {
            Image(systemName: flashMode.imageName).padding()
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
