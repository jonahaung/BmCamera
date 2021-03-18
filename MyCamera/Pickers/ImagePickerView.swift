//
//  ImagePickerView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 1/12/20.
//

import SwiftUI

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
                
                picker.dismiss(animated: true) {
                    Photo.create(data: data, isVideo: false)
                }
            } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL, let data = try? Data(contentsOf: videoURL) {
                picker.dismiss(animated: true) {
                    Photo.create(data: data, isVideo: true)
                }
                
            }
        }
    }
}

