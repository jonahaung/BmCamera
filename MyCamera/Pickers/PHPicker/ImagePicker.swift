//
//  ImagePicker.swift
//  SwiftUIPHPickerApp
//
//  Copyright © 2020 manato. All rights reserved.
//

import PhotosUI
import SwiftUI

// Import PromiseKit
import PromiseKit

enum ImageError: Error {
    case unwrapped
}

struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    
    var configuration: PHPickerConfiguration {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        //        config.filter = .videos
        config.selectionLimit = 10
        return config
    }
    
    // Return array of UIImage
    var completion: ((_ selectedImage: [Photo]) -> Void)? = nil
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_: PHPickerViewController, context _: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            Promise.value(results).thenMap(load).done { photos in
                
                self.parent.completion?(photos)
                self.parent.presentationMode.wrappedValue.dismiss()
            }.catch { error in
                print(error.localizedDescription)
            }
            
        }
        
        // Return the loaded value wrapped Promise
        private func load(_ image: PHPickerResult) -> Promise<Photo> {
            Promise { seal in
                if image.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    image.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { (data, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            seal.reject(error)
                            return
                        }
                        
                        guard let data = data, let photo = Photo.create(data: data, isVideo: false) else {
                            print("unable to unwrap image as UIImage")
                            seal.reject(ImageError.unwrapped)
                            return
                        }
                        
                        seal.fulfill(photo)
                    }
                } else if image.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    image.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.movie.identifier) { (data, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            seal.reject(error)
                            return
                        }
                        
                        guard let data = data, let photo = Photo.create(data: data, isVideo: true) else {
                            print("unable to unwrap image as UIImage")
                            seal.reject(ImageError.unwrapped)
                            return
                        }
                        
                        seal.fulfill(photo)
                    }
                }
                
            }
        }
    }
}
