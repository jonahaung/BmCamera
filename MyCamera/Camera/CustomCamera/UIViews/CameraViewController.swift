/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's primary view controller that presents the camera interface.
*/

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    
    let manager: CameraManager
    var previewView: PreviewView
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        previewView.videoPreviewLayer.videoGravity = .resizeAspect
        let gesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap(_:)))
        previewView.addGestureRecognizer(gesture)
        previewView.backgroundColor = .darkText
    }
    
    init(_manager: CameraManager) {
        manager = _manager
        previewView = _manager.previewView
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = previewView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        manager.willAppear()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        manager.willDisappear()
//        super.viewWillDisappear(animated)
//    }
    
  
    override var shouldAutorotate: Bool {
        // Disable autorotation of the interface when recording is in progress.
        if let movieFileOutput = manager.movieFileOutput {
            return !movieFileOutput.isRecording
        }
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
                deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                    return
            }
            
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    @objc private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let focusRectangle = FocusRectangleView(touchPoint: gestureRecognizer.location(in: view))
        view.addSubview(focusRectangle)
        manager.focusAndExposeTap(gestureRecognizer)
    }
}

