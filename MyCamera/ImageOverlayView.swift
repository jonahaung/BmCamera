//
//  ImageOverlayView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 19/3/21.
//

import SwiftUI

struct ImageOverlayView: View {
    
    @Binding var photo: Photo?
    @State var dragOffset: CGSize = CGSize.zero
    @State var dragOffsetPredicted: CGSize = CGSize.zero
    
    var body: some View {
        ZStack {
            
            if let image = photo?.originalImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .offset(x: self.dragOffset.width, y: self.dragOffset.height)
                    .rotationEffect(.init(degrees: Double(self.dragOffset.width / 30)))
                    .gesture(DragGesture()
                        .onChanged { value in
                            self.dragOffset = value.translation
                            self.dragOffsetPredicted = value.predictedEndTranslation
                        }
                        .onEnded { value in
                            if((abs(self.dragOffset.height) + abs(self.dragOffset.width) > 400) || ((abs(self.dragOffsetPredicted.height)) / (abs(self.dragOffset.height)) > 3) || ((abs(self.dragOffsetPredicted.width)) / (abs(self.dragOffset.width))) > 3) {
                                photo = nil
                                dragOffset = .zero
                                dragOffsetPredicted = .zero
                                return
                            }
                            self.dragOffset = .zero
                        }
                    )
            }
        }.background(Color.black).opacity(photo == nil ? 0 : 1)
    }
}
