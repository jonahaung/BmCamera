//
//  ImageViewerView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import SwiftUI
import AVKit

struct ImageViewerView: View {
    
    let photo: Photo
    @Environment(\.presentationMode) var presentationMode
    @State private var isFavourite = false
    
    init(photo: Photo) {
        self.photo = photo
        self.isFavourite = photo.isFavourite
    }
    
    var body: some View {
        NavigationView{
            VStack {
                
                Spacer()
                if photo.isVideo, let url = photo.mediaUrl {
                    VideoPlayer(player: AVPlayer(url:  url))
                }else {
                    if let image = photo.originalImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .pinchToZoom()
                    }
                    
                }
                Spacer()
                if Utils.isPotrait() {
                    bottomBar()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            , trailing: Text(Int(photo.fileSize).byteSize).font(.footnote))
            .navigationTitle("\(photo.date ?? Date(), formatter: relativeDateFormat)")
            .onAppear{
                isFavourite = photo.isFavourite
            }
        }
        
    }

    
    private func bottomBar() -> some View {
        return HStack {
            
            Button {
                if let url = photo.mediaUrl {
                    share(items: [url])
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            
            Spacer()
            Button {
                SoundManager.vibrate(vibration: .selection)
                photo.isFavourite.toggle()
                isFavourite = photo.isFavourite
            } label: {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
            
            }
            Spacer()
            Button {
                let action = {
                    Photo.delete(photo: photo)
                   
                    presentationMode.wrappedValue.dismiss()
                }
                let actionPair = ActionPair("Confirm Delete", action, .destructive)
                AlertPresenter.presentActionSheet(title: "Delete this item?", actions: [actionPair])
                
            } label: {
                Image(systemName: "trash")
            }
            
        }.padding()
    }
    
    private func share(items: [Any]) {
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.getTopViewController()?.present(ac, animated: true)
    }
}

// Our custom view modifier to track rotation and
// call our action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
