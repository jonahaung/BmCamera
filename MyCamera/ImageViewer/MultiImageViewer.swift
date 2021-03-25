//
//  MultiImageViewer.swift
//  MyCamera
//
//  Created by Aung Ko Min on 19/3/21.
//

import SwiftUI
import AVKit
struct MultiImageViewer: View {
    
    @State var photos: [Photo]
    @State var currentPhoto: Photo
    @Environment(\.presentationMode) var presentationMode
    @State private var showControls = true
    
    var body: some View {
        ZStack {
            Color(showControls ? .systemBackground : .label).edgesIgnoringSafeArea(.all)
            TabView(selection: $currentPhoto,
                    content:  {
                        ForEach(photos) { photo in
                            Group{
                                if photo.isVideo, let url = photo.mediaUrl {
                                    VideoPlayer(player: AVPlayer(url:  url))
                                }else {
                                    
                                    if let image = photo.thumbnil {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                            }.tag(photo)
                            
                            .onTapGesture {
                                withAnimation{
                                    showControls.toggle()
                                }
                            }
                        }
                    })
                
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            if showControls {
                VStack {
                    Spacer()
                    bottomBar()
                }
            }
        }
        
    }
    
    private func bottomBar() -> some View {
        return HStack {
            
            Button {
                if let url = currentPhoto.mediaUrl {
                    share(items: [url])
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            Spacer()
            Button {
                
                let action = {
                    Photo.delete(photo: currentPhoto)
                    presentationMode.wrappedValue.dismiss()
                }
                let actionPair = ActionPair("Confirm Delete", action, .destructive)
                AlertPresenter.presentActionSheet(actions: [actionPair])
                
            } label: {
                Image(systemName: "trash.fill")
            }
            Spacer()
            Button {
                
                if let i = photos.firstIndex(of: currentPhoto) {
                    currentPhoto.isFavourite.toggle()
                    photos.remove(at: i)
                    photos.insert(currentPhoto, at: i)
                }
            } label: {
                Image(systemName: currentPhoto.isFavourite ? "heart.fill" : "heart")
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
