//
//  DeviceVideoCamera.swift
//  MyCamera
//
//  Created by Aung Ko Min on 10/3/21.
//

import SwiftUI

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    
    var observer: CameraManager
    
    typealias UIViewControllerType = CameraViewController
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraViewControllerRepresentable>) -> CameraViewController {
        let vc = CameraViewController(_manager: observer)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CameraViewControllerRepresentable>) {
        
    }
    
    class Coordinator: NSObject {

    }
}
