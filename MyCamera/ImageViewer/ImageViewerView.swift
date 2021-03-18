//
//  ImageViewerView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import SwiftUI
import AVKit

struct ImageViewerView: View {
    
    @State var photo: Photo
    @Environment(\.presentationMode) var presentationMode
    @State private var showImageViewer = false
    @State private var image = Image(systemName: "circle.fill")
    @State private var isFavourite = false
    
    var body: some View {
        VStack {
            Spacer()
            if photo.isVideo, let url = photo.mediaUrl {
                VideoPlayer(player: AVPlayer(url:  url))
            }else {
               
                image
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        showImageViewer.toggle()
                    }
                    .navigationBarHidden(showImageViewer)
            }
            Spacer()
            if Utils.isPotrait() {
                bottomBar()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(photo.date ?? Date(), formatter: relativeDateFormat)")
        .overlay(ImageViewer(image: $image, viewerShown: $showImageViewer))
        .onAppear{
            if let image = photo.image() {
                self.image = Image(uiImage: image)
            }
            
            self.isFavourite = photo.isFavourite
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
                
                let action: Action = {
                    Photo.delete(photo: photo)
                    presentationMode.wrappedValue.dismiss()
                }
                let actionPair = ActionPair("Confirm Delete",action)
                AlertPresenter.presentActionSheet(actions: [actionPair])
                
            } label: {
                Image(systemName: "trash.fill")
            }
            Spacer()
            Button {
                photo.isFavourite.toggle()
                PersistenceController.shared.save()
                isFavourite = photo.isFavourite
            } label: {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .foregroundColor(.red)
            }
            Spacer()
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Done")
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
