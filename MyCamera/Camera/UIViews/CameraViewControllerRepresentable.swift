//
//  DeviceVideoCamera.swift
//  MyCamera
//
//  Created by Aung Ko Min on 10/3/21.
//

import SwiftUI

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    
    let manager: CameraManager
    
    typealias UIViewControllerType = CameraViewController
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraViewControllerRepresentable>) -> CameraViewController {
        return CameraViewController(_manager: manager)
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CameraViewControllerRepresentable>) {
        
    }
    
    class Coordinator: NSObject {

    }
}
