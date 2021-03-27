//
//  ImageGallaryCell.swift
//  MyCamera
//
//  Created by Aung Ko Min on 11/3/21.
//

import SwiftUI

struct ImageGallaryCell: View {
    
    @StateObject var photoItem: PhotoItem
    let isEditing: Bool
    
    var body: some View {
        if let image = photoItem.thumbnil {
            ZStack(alignment: .bottom) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(5)
                HStack {
                    if isEditing {
                        if photoItem.isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .padding(1)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                    } else {
                        if photoItem.isVideo {
                            if let duration = photoItem.photo.duration, duration > 0 {
                                Text(Int(duration).secondsTodDuration())
                                    .font(.footnote)
                                    .bold()
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                            } else {
                                Image(systemName: "video.fill")
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                                
                            }
                        }
                        Spacer()
                        Button {
                            SoundManager.vibrate(vibration: .soft)
                            photoItem.photo.isFavourite.toggle()
                        } label: {
                            let imageName = photoItem.isFavourite ? "heart.fill" : "heart"
                            Image(systemName: imageName)
                                .font(.system(size: 18, weight: .light))
                                .shadow(radius: 5)
                                .foregroundColor(.white)
                        }
                    }
                }.padding(5)
            }
        }
        
        
    }
}
