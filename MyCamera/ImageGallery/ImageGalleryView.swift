//
//  ImageGalleryView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import SwiftUI

struct ImageGalleryView: View {
    
    enum SheetType: Identifiable {
        var id: SheetType { return self }
        case imagePicker, documentPicker, logIn, imageViewer
    }
    enum ActionSheetType: Identifiable {
        var id: ActionSheetType { return self }
        case importMenu, filterMenu, infoMenu
    }
    
    @StateObject private var manager = ImageGalleryManager()
    @State private var fullScreenViewType: SheetType? = .logIn
    @State private var menuType: ActionSheetType?
    @State private var isEditing = false
    @State private var filterMode = ImageGalleryFilterMode.all
    
    var body: some View {
        VStack {
            if manager.folderName == nil {
                accessDeniedView
            } else {
                ScrollView(showsIndicators: false) {
                    
                    Divider()
                    
                    ForEach(manager.sections) { sectionItem in
                        ImageGallerySection(sectionItem: sectionItem, isEditing: isEditing) { photoItem in
                            didTapPhotoCell(photoItem: photoItem)
                        }
                    }
                    
                    Section{
                        let text = manager.sections.isEmpty ? "No Photos or Videos\nYou can take photos and videos using the camera, or import photos and videos from your device photo album" : "Total \(manager.sections.count) sections"
                        Text(text)
                            .font(.title3)
                            .foregroundColor(Color(.quaternaryLabel))
                            .padding()
                        
                    }
                }.padding(.horizontal, 3)
                HStack {
                    if isEditing {
                        editingBottomBarItems
                    }else {
                        nonEditingBottomBarItems
                    }
                }.padding()
                
                .navigationTitle(filterMode.description)
                .navigationBarItems(trailing: settingsButton)
                .onDisappear{
                    print("Disappear")
                    manager.clear()
                }
            }
        }
        
        .actionSheet(item: $menuType, content: { type in
            switch type {
            case ActionSheetType.importMenu:
                return importMenu()
            case .filterMenu:
                return filterMenu()
            case .infoMenu:
                return infoMenu()
            }
        })
        .sheet(item: $fullScreenViewType) { mode in
            switch mode {
            case .imageViewer:
                if let photo = manager.selectedPhoto {
                    ImageViewerView(photo: photo)
                }
            case .imagePicker:
                ImagePicker().edgesIgnoringSafeArea(.all)
            case .logIn:
                LockScreenView(lockScreenType: .viewPhotoGallery) { [self] folderName in
                    manager.folderName = folderName
                    manager.fetchPhotos(filterMode: .all)
                }
            case .documentPicker:
                DocPickerView()
            }
        }
        
    }
    
    private func didTapPhotoCell(photoItem: PhotoItem) {
        if isEditing {
            if photoItem.isSelected {
                if let index = manager.selectedItems.firstIndex(of: photoItem) {
                    manager.selectedItems.remove(at: index)
                    SoundManager.vibrate(vibration: .soft)
                }
                photoItem.isSelected = false
            } else {
                if !manager.selectedItems.contains(photoItem) {
                    manager.selectedItems.append(photoItem)
                    SoundManager.vibrate(vibration: .soft)
                }
                photoItem.isSelected = true
            }
        } else {
            manager.selectedPhoto = photoItem.photo
            fullScreenViewType = .imageViewer
        }
    }
}

extension ImageGalleryView {
    
    private var accessDeniedView: some View {
        return VStack(alignment: .center, spacing: 10) {
            VStack(spacing: 5) {
                Text("Access Denied")
                    .font(.title)
                Text("Please authenticate to view your photos and videos")
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.secondary)
            
            Button(action: {
                fullScreenViewType = .logIn
            }, label: {
                Text("Login").underline()
            })
        }
        .padding()
    }
    private var selectButton: some View {
        return Button(isEditing ? "Done" : "Select") {
            isEditing.toggle()
            manager.selectedItems.removeAll()
        }
    }
    
    private var settingsButton: some View {
        return Button(action: {
            menuType = .infoMenu
        }) {
            Image(systemName: "lock.open").padding()
        }
    }
    
    private var nonEditingBottomBarItems: some View {
        return Group {
            Button("Import") {
                menuType = .importMenu
            }
            Spacer()
            Button("Filter") {
                menuType = .filterMenu
            }
            Spacer()
            selectButton
        }
        
    }
    private var editingBottomBarItems: some View {
        return Group {
            Button {
                let urls = manager.selectedItems.map{ $0.photo.mediaUrl}
                let ac = UIActivityViewController(activityItems: urls as [Any], applicationActivities: nil)
                UIApplication.getTopViewController()?.present(ac, animated: true)
            } label: {
                Image(systemName: "square.and.arrow.up")
            }.disabled(manager.selectedItems.isEmpty)
            Spacer()
            
            Button {
                let items = manager.selectedItems
                let action: Action = {
                    manager.selectedItems.forEach{ item in
                        
                        Photo.delete(photo: item.photo)
                    }
                }
                isEditing = false
                let actionPair = ActionPair("Confirm Delete",action, .destructive)
                AlertPresenter.presentActionSheet(title: "Deleting \(items.count) items ?", actions: [actionPair])
                
            } label: {
                Image(systemName: "trash")
            }.disabled(manager.selectedItems.isEmpty)
            Spacer()
            selectButton
        }
        
    }
}


extension ImageGalleryView {
    
    private func infoMenu() -> ActionSheet {
        return ActionSheet(
            title: Text("Passcoad: \(UserdefaultManager.shared.currentFolderName ?? "")"),
            buttons: [
                .default(Text("Switch to another album"), action: {
                    fullScreenViewType = .logIn
                }),
                .default(Text("Logout"), action: {
                    self.manager.folderName = nil
                }),
                .destructive(Text("Delete Album"), action: {
                    AlertPresenter.show(title: "Are you sure to delete this album") { done in
                        if done {
                            manager.sections.forEach{ section in
                                section.photoItems.forEach{
                                    Photo.delete(photo: $0.photo)
                                }
                            }
                            manager.fetchPhotos(filterMode: .all)
                        }
                    }
                }),
                .cancel()
            ]
        )
    }
    
    private func importMenu() -> ActionSheet {
        return ActionSheet(
            title: Text("Import Options"),
            buttons: [
                .default(Text("Import from Photo Library"), action: {
                    fullScreenViewType = .imagePicker
                }),
                .default(Text("Import from Files"), action: {
                    fullScreenViewType = .documentPicker
                }),
                .cancel()
            ]
        )
    }
    
    
    private func filterMenu() -> ActionSheet {
        
        var buttons: [ActionSheet.Button] = []
        ImageGalleryFilterMode.allCases.forEach { mode in
            if mode != self.filterMode {
                let button = ActionSheet.Button.default(Text(mode.description)) {
                    self.filterMode = mode
                    self.manager.fetchPhotos(filterMode: mode)
                }
                buttons.append(button)
            }
        }
        buttons.append(.cancel())
        
        return ActionSheet( title: Text("Filter Options"), buttons: buttons)
    }
}





