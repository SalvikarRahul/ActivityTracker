//
//  ViewController.swift
//  ActivityTracker
//
//  Created by Rahul on 04/07/24.
//

import Foundation
import UIKit
import AVFoundation

class ViewController: UIViewController {
    private lazy var cameraService = CameraService()
    private weak var button: UIButton?
    private weak var imagePreviewView: UIImageView?
    private var cameraInited = false
    
    private enum ButtonState { case cancel, makeSnapshot }
    private var buttonState = ButtonState.makeSnapshot {
        didSet {
            switch buttonState {
                case .makeSnapshot: button?.setTitle("Make a photo", for: .normal)
                case .cancel: button?.setTitle("Cancel", for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraPreviewView()
//         setupButton()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraService.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraService.stop()
    }

    // Ensure that the interface stays locked in Portrait.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // Ensure that the interface stays locked in Portrait.
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}


extension ViewController {

    private func setupCameraPreviewView() {
        let previewView = UIView(frame: .zero)
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

    private func setupButton() {
        let button = UIButton(frame: .zero)
        button.addTarget(self, action: #selector(buttonTouchedUpInside), for: .touchUpInside)
        view.addSubview(button)
        self.button = button
        buttonState = .makeSnapshot
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }

    private func show(image: UIImage) {
        let imageView = UIImageView(frame: .zero)
        view.insertSubview(imageView, at: 1)
        imagePreviewView = imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.image = image
    }

    @objc func buttonTouchedUpInside() {
        switch buttonState {
        case .makeSnapshot:
            cameraService.capturePhoto { [weak self] image in
                guard let self = self else {return }
                self.cameraService.stop()
                self.buttonState = .cancel
                self.show(image: image)
            }
        case .cancel:
            buttonState = .makeSnapshot
            cameraService.start()
            imagePreviewView?.removeFromSuperview()
        }
    }
}
