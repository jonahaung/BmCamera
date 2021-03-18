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
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocPickerView>) -> UIDocumentPickerViewController {
        let x = UIDocumentPickerViewController(documentTypes: [String(kUTTypeJPEG), String(kUTTypePNG)], in: .open)
        x.delegate = context.coordinator
        
        return x
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocPickerView>) {
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
        
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
                    Photo.create(data: data, isVideo: false)
                }
            }
        }
        
        
    }
}


