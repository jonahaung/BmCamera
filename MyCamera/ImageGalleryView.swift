//
//  ImageGalleryView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import SwiftUI

enum ImportSource: Identifiable {
    var id: ImportSource { return self }
    case photoLibrary, files
}
enum MenuType: Identifiable {
    var id: MenuType { return self }
    case importMenu, sortMenu
}

struct ImageGalleryView: View {
    
    @State private var selectedPhotos = [Photo]()
   @StateObject private var manager = ImageGalleryManager()
    
    @EnvironmentObject var currentLoginSession: CurrentLoginSession
    @Environment(\.presentationMode) var presentationMode
    
    @State private var importMode: ImportSource?
    @State private var menuType: MenuType?
    @State private var currentGrid: Int = 2
    @State private var isEditing = false
   
    var body: some View {
        NavigationView{
            VStack {
                if currentLoginSession.folderName != nil {
                    ScrollView(showsIndicators: false) {
                        
                        ForEach(manager.sections) { section in
                            Section(header: getHeader(for: section.date)) {
                                Grid(section.photos) { photo in
                                    ImageGallaryCell(photo: photo, isEditing: isEditing, isSelected: isEditing && selectedPhotos.contains(photo))
                                        .frame(minHeight: 100)
                                    .onTapGesture {
                                        toggleSelect(photo: photo)
                                    }
                                }
                                .animation(.easeInOut)
                                .gridStyle(StaggeredGridStyle(.vertical, tracks: .count(section == manager.sections.first ? currentGrid : currentGrid + 1), spacing: 3))
                            }
                            Divider()
                        }

                    }
                    
                } else {
                    Spacer()
                    ActivityIndicatorView()
                }
                Spacer()
                if isEditing {
                    editingBottomBar()
                } else {
                    bottomBar()
                }
                
            }
            .padding(.horizontal, 5)
            .navigationTitle(isEditing ? "Editing" : "Gallery")
            .navigationBarItems(trailing: editButton)
            .actionSheet(item: $menuType, content: { type in
                switch type {
                case MenuType.importMenu:
                    return importMenu()
                case MenuType.sortMenu:
                    return sortMenu()
                }
            })
            .sheet(item: $importMode) { mode in
                if mode == ImportSource.photoLibrary {
                    ImagePickerView()
                } else {
                    DocPickerView()
                }
            }
        }
        .fullScreenCover(isPresented: $currentLoginSession.isLoggingIn) {
            LockScreenView().environmentObject(currentLoginSession).onDisappear{
                if currentLoginSession.folderName != nil {
                    manager.fetchPhoto()
                }
            }
        }
        .onAppear{
            currentLoginSession.isLoggingIn = true
            
        }
    }
    
    private func getHeader(for date: Date) -> some View {
        return HStack {
            Text("\(date, formatter: relativeDateFormat)").font(Font.system(size: 25, weight: .heavy, design: .rounded))
            Spacer()
            Button(action: {
                menuType = .sortMenu
            }) {
                Image(systemName: "equal")
            }
        }.padding()
    }
    private func toggleSelect(photo: Photo) {
        guard isEditing else { return }
        SoundManager.vibrate(vibration: .selection)
        if selectedPhotos.contains(photo) {
            if let index = selectedPhotos.firstIndex(of: photo) {
                selectedPhotos.remove(at: index)
            }
        } else {
            selectedPhotos.append(photo)
        }
    }
}


extension ImageGalleryView {
    
    private var editButton: some View {
        return Button(action: {
            isEditing.toggle()
            selectedPhotos.removeAll()
            currentGrid = isEditing ? 3 : 2
        }) {
            Text(isEditing ? "Done" : "Edit")
        }
    }
    private func bottomBar() -> some View {
        HStack{
            Button("Import") {
                menuType = .importMenu
            }
            Spacer()
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
        }.padding(.horizontal)
        
    }
    private func editingBottomBar() -> some View {
        HStack{
            Button {
                let urls = selectedPhotos.map{ $0.mediaUrl}
                let ac = UIActivityViewController(activityItems: urls as [Any], applicationActivities: nil)
                UIApplication.getTopViewController()?.present(ac, animated: true)
            } label: {
                Image(systemName: "square.and.arrow.up")
            }.disabled(selectedPhotos.isEmpty)
            
            Button("Select All") {
                selectedPhotos = manager.photos
            }
            Spacer()
            Button("Deselect") {
                selectedPhotos = []
            }.disabled(selectedPhotos.isEmpty)
            Spacer()
            Text("\(selectedPhotos.count)").foregroundColor(.secondary)
            Spacer()
            Button {
                let action: Action = {
                    selectedPhotos.forEach{ photo in
                        if let index = manager.photos.firstIndex(of: photo) {
                            manager.photos.remove(at: index)
                            Photo.delete(photo: photo)
                        }
                        
                    }
                    manager.fetchPhoto()
                    isEditing = false
                }
                let actionPair = ActionPair("Confirm Delete",action)
                AlertPresenter.presentActionSheet(actions: [actionPair])
                
            } label: {
                Image(systemName: "trash")
            }.disabled(selectedPhotos.isEmpty).accentColor(.red)
        }.padding(.horizontal)
    }
}


extension ImageGalleryView {
    
    private func importMenu() -> ActionSheet {
        return ActionSheet(
            title: Text("Import Options"),
            buttons: [
                .default(Text("Import from Photo Library"), action: {
                    importMode = .photoLibrary
                }),
                .default(Text("Import from Files"), action: {
                    importMode = .files
                }),
                .cancel()
            ]
        )
    }
    
    private func sortMenu() -> ActionSheet {
        return ActionSheet(
            title: Text("Sorting Options"),
            buttons: [
                .default(Text("1 x column"), action: {
                    currentGrid = 1
                }),
                .default(Text("2 x column"), action: {
                    currentGrid = 2
                }),
                .default(Text("3 x column"), action: {
                    currentGrid = 3
                }),
                .cancel()
            ]
        )
    }
}


