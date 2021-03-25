//
//  DocPickerView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 13/12/20.
//

import SwiftUI
import MobileCoreServices
import PDFKit

struct DocPickerView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIDocumentPickerViewController
    
    let completion: (_ selectedImage: [Photo]) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocPickerView>) -> UIDocumentPickerViewController {
        
        let x = UIDocumentPickerViewController(forOpeningContentTypes: [.video, .jpeg, .png, .avi, .image])
        x.delegate = context.coordinator
        
        return x
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocPickerView>) {
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        
        
        let parent: DocPickerView
        
        init(_ parent: DocPickerView) {
            self.parent = parent
        }
        
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first, url.startAccessingSecurityScopedResource() {
                defer {
                    DispatchQueue.main.async {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                if let image = UIImage(contentsOfFile: url.path), let data = image.jpegData(compressionQuality: 1) {
                    if let photo = Photo.create(data: data, isVideo: false) {
                        parent.completion([photo])
                    }
                    
                }
            }
        }
        
        
    }
}


