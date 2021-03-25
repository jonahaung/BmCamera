//
//  ImagePickerView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 1/12/20.
//

import SwiftUI
import Photos

struct ImagePickerView: UIViewControllerRepresentable {

    typealias UIViewControllerType = UIImagePickerController
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let x = UIImagePickerController()
        x.sourceType = .photoLibrary
        x.mediaTypes = ["public.image", "public.movie"]
        x.allowsEditing = false
        x.delegate = context.coordinator
        
        return x
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = (info[.originalImage]) as? UIImage, let data = image.jpegData(compressionQuality: 1) {
                _ = Photo.create(data: data, isVideo: false)
                picker.dismiss(animated: true) {
                    
                }
            } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL, let data = try? Data(contentsOf: videoURL) {
                _ = Photo.create(data: data, isVideo: true)
                picker.dismiss(animated: true) {
                   
                }
                
            }
            if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
                let alert = UIAlertController(title: "Delete Original Image?", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete Source", style: .destructive, handler: { x in
                    PHPhotoLibrary.shared().performChanges( {
                        let imageAssetToDelete = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                        PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
                    },
                        completionHandler: { success, error in
                            
                    })
                }))
            }

        }
        
        private func askToDelete(url: URL) {
            
        }
    }
}



