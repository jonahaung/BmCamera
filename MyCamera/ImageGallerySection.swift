//
//  ImageGallerySection.swift
//  BmCamera
//
//  Created by Aung Ko Min on 27/3/21.
//

import SwiftUI

struct ImageGallerySection: View {
    
    @StateObject var sectionItem: PhotoSectionItem
    let isEditing : Bool
    var onTap: ((_ photoItem: PhotoItem) -> Void)? = nil
    var body: some View {
        Section(header: getHeader(), footer: Divider().padding(.horizontal)) {
            
            if sectionItem.show {
                Grid(sectionItem.photoItems) { item in
                    ImageGallaryCell(photoItem: item, isEditing: isEditing)
                        .frame(minHeight: sectionItem.photoItems.count <= 3 ? 150 : 70)
                        .onTapGesture {
                            onTap?(item)
                        }
                }
                .animation(.easeInOut)
                .gridStyle(StaggeredGridStyle(.vertical, tracks: .count(sectionItem.currentGrid)))
            }
        }
    }
    
    private func getHeader() -> some View {
        return VStack {
            ZStack {
                if let headItem = sectionItem.headItem, let image = headItem.thumbnil {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(5)
                }
                VStack {
                    Spacer()
                    
                    Text("\(sectionItem.date, formatter: relativeDateFormat)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    
                    Text("Total \(sectionItem.photoItems.count) items")
                        .font(.title).bold()
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                    
                    Spacer()
                    Spacer()
                    Button {
                        SoundManager.vibrate(vibration: .soft)
                        withAnimation{
                            sectionItem.show.toggle()
                        }
                        
                    } label: {
                        Image(systemName: sectionItem.show ? "chevron.up" : "chevron.down")
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle()).shadow(radius: 5)
                    }
                    Spacer()
                }
            }
            if sectionItem.show {
                topBar
            }
            
        }
    }
    
    private var topBar: some View {
        return Picker(selection: $sectionItem.currentGrid, label: Image(systemName: "rectangle.3.offgrid")) {
            Image(systemName: "rectangle.grid.1x2.fill").tag(1)
            Image(systemName: "rectangle.grid.2x2.fill").tag(2)
            Image(systemName: "rectangle.grid.3x2.fill").tag(3)
        }
        .pickerStyle(SegmentedPickerStyle())
        
    }
}


