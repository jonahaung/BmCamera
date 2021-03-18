//
//  ImageGalleryView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import SwiftUI
extension EditMode {

    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
struct ImageGalleryView: View {
    
    @FetchRequest(fetchRequest: Photo.allFetchRequest)
    var photos: FetchedResults<Photo>
    @State private var selectedPhotos = [Photo]()
    
    enum ImportSource: Identifiable {
        var id: ImportSource { return self }
        case photoLibrary, files
    }
    @State private var importMode: ImportSource?
    @State private var showActionSheet = false
    @EnvironmentObject var currentLoginSession: CurrentLoginSession
    @Environment(\.presentationMode) var presentationMode
    @State private var currentGrid = 1
    @State private var isEditing = false
    
    private var columns: [GridItem] {
        var columns = 1
       
        switch currentGrid {
        case 0:
            columns = 3
        case 1:
            columns = 2
        case 2:
            columns = 1
        default:
            break
        }
        return Array(repeating: .init(.flexible()), count: columns)
    }
    
    @State var albumName: String?
    
    
    var body: some View {
        NavigationView{
            VStack {
                if currentLoginSession.folderName != nil {
                    ScrollView {
                        
                        LazyVGrid(columns: columns, pinnedViews: [.sectionHeaders]) {
                            Section(header: headerBar()) {
                                ForEach(photos) { photo in
                                    NavigationLink(destination: ImageViewerView(photo: photo)) {
                                        ImageGallaryCell(photo: photo)
                                    }.disabled(isEditing).opacity(selectedPhotos.contains(photo) ? 0.3 : 1).onTapGesture {
                                        guard isEditing else { return }
                                        SoundManager.playSound(tone: .Tock)
                                        if selectedPhotos.contains(photo) {
                                            if let index = selectedPhotos.firstIndex(of: photo) {
                                                selectedPhotos.remove(at: index)
                                            }
                                        } else {
                                            selectedPhotos.append(photo)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 5)
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
            .navigationTitle(isEditing ? "Editing" : "Gallery")
            .navigationBarItems(trailing: editButton)
            .actionSheet(isPresented: $showActionSheet, content: editMenu)
            .sheet(item: $importMode) { mode in
                if mode == ImportSource.photoLibrary {
                    ImagePickerView()
                } else {
                    DocPickerView()
                }
            }
        }
        
        .fullScreenCover(isPresented: $currentLoginSession.isLoggingIn) {
            LockScreenView().environmentObject(currentLoginSession)
        }
        .onAppear{
            currentLoginSession.isLoggingIn = true
        }
    }
}


extension ImageGalleryView {
    
    private var editButton: some View {
        return Button(action: {
            SoundManager.playSound(tone: .Tock)
            withAnimation{
                isEditing.toggle()
                selectedPhotos.removeAll()
            }
        }) {
            Text(isEditing ? "Done" : "Edit")
        }
    }
    private func bottomBar() -> some View {
        HStack{
            Button("Import") {
                showActionSheet = true
            }
            Spacer()
            if currentLoginSession.folderName != nil {
                Text("\(photos.count) items").foregroundColor(.secondary)
                Spacer()
            }
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
        }.padding()
        
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
                selectedPhotos = Array(photos)
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
                        Photo.delete(photo: photo)
                    }
                }
                let actionPair = ActionPair("Confirm Delete",action)
                AlertPresenter.presentActionSheet(actions: [actionPair])
            
            } label: {
                Image(systemName: "trash")
            }.disabled(selectedPhotos.isEmpty).accentColor(.red)
        }.padding()
        
    }
    private func trailingButton() -> some View {
        return HStack {
            Spacer()
            EditButton()
        }
        
    }
    private func headerBar() -> some View {
        return HStack {
            Picker(selection: $currentGrid, label: Text("")) {
                Image(systemName: "square.grid.3x2.fill").tag(0)
                Image(systemName: "square.grid.2x2.fill").tag(1)
                Image(systemName: "rectangle.grid.1x2.fill").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Spacer()
            
        }.padding()
        
    }
}


extension ImageGalleryView {
    
    private func editMenu() -> ActionSheet {
        return ActionSheet(
            title: Text(String()),
            message: Text(String()),
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
}
