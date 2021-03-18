//
//  ImageGallaryCell.swift
//  MyCamera
//
//  Created by Aung Ko Min on 11/3/21.
//

import SwiftUI

struct ImageGallaryCell: View {
    
    let photo: Photo
    let isEditing: Bool
    let isSelected: Bool
    @State private var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let image = self.image {
                NavigationLink(destination: ImageViewerView(photo: photo), label: {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(5)
                }).disabled(isEditing)
                HStack {
                    if photo.isVideo {
                        Image(systemName: "video.fill")
                            .foregroundColor(.yellow)
                    }
                    if isEditing {
                        let imageName = isSelected ? "checkmark.circle.fill" : "circle"
                        Image(systemName: imageName)
                            .foregroundColor(.white)
                    }

                    if photo.isFavourite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                }
                .font(.title3)
                .padding(7)
            }
        }
        .onAppear{
            if image == nil {
                Async.userInitiated {
                    let image = photo.thumbnil()
                    Async.main {
                        self.image = image
                    }
                }
            }
        }
    }
}

