//
//  ImageGallaryCell.swift
//  MyCamera
//
//  Created by Aung Ko Min on 11/3/21.
//

import SwiftUI

struct ImageGallaryCell: View {
    
    let photo: Photo
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let url = photo.mediaUrl {
                AsyncImage(url: url, isVideo: photo.isVideo, placeholder: { ActivityIndicatorView() }, image: { Image(uiImage: $0) })
            }
            HStack {
                Spacer()
                if photo.isFavourite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }.padding(7)
        }
    }
}

