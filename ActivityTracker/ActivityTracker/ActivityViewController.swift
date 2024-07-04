//
//  ActivityViewController.swift
//  ActivityTracker
//
//  Created by Rahul on 04/07/24.
//

import UIKit

class ActivityViewController: UIViewController {
    var activity: ActivityModel? = nil
    var cameraService = CameraService()
    let previewView = UIView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraPreviewView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraService.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
            self.removePreviewScreen()
            self.cameraService.stop()
        })
    }
    /*
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraService.stop()
    }
    */
    // Ensure that the interface stays locked in Portrait.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // Ensure that the interface stays locked in Portrait.
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

extension ActivityViewController {
    
    private func setupCameraPreviewView() {
        view.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        previewView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        previewView.layoutIfNeeded()
        cameraService.prepare(previewView: previewView, cameraPosition: .back) { [weak self] success in
            if success { self?.cameraService.start() }
        }
    }
    
    private func removePreviewScreen() {
        previewView.removeFromSuperview()
    }
}
