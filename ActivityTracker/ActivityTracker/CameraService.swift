//
//  CameraService.swift
//  CoreMLDemo
//
//  Created by Rahul on 16/01/22.
//

/*

Use full information
https://github.com/TUNER88/iOSSystemSoundsLibrary#screenshot
Timer_Haptic

HealthNotificationUrgent

Alarm_nightstand_Haptic

RingtoneDucked_US_haptic

Ringtone_UK_haptic

WorkoutComplete_Haptic

Ringtone_2_haptic-sashimi

Ringtone_us_haptic

SWTest1_Haptic
*/


import UIKit
import AVFoundation
import Vision

protocol CameraServiceDelegate: AnyObject {
    func activityDetected(date: Date, dateInt64: Int64, selectedItem: String)
}

class CameraService: NSObject {
    var player: AVAudioPlayer?
    weak var cameraServiceDelegate: CameraServiceDelegate?
    private weak var previewView: UIView?
    private(set) var cameraIsReadyToUse = false
    private let session = AVCaptureSession()
    private weak var previewLayer: AVCaptureVideoPreviewLayer?
    private lazy var sequenceHandler = VNSequenceRequestHandler()
    private lazy var capturePhotoOutput = AVCapturePhotoOutput()
    private lazy var dataOutputQueue = DispatchQueue(label: "FaceDetectionService",
                                                     qos: .userInitiated, attributes: [],
                                                     autoreleaseFrequency: .workItem)
    private var captureCompletionBlock: ((UIImage) -> Void)?
    private var preparingCompletionHandler: ((Bool) -> Void)?
    private var snapshotImageOrientation = UIImage.Orientation.upMirrored
    var searchTextArray: [String]? = nil
    private var cameraPosition = AVCaptureDevice.Position.front {
        didSet {
            switch cameraPosition {
                case .front: snapshotImageOrientation = .upMirrored
                case .unspecified, .back: snapshotImageOrientation = .up //fallthrough
                @unknown default: snapshotImageOrientation = .up
            }
        }
    }
    func prepare(previewView: UIView,
                 cameraPosition: AVCaptureDevice.Position,
                 completion: ((Bool) -> Void)?) {
        self.previewView = previewView
        self.preparingCompletionHandler = completion
        self.cameraPosition = cameraPosition
        checkCameraAccess { allowed in
            if allowed { self.setup() }
            completion?(allowed)
            self.preparingCompletionHandler = nil
        }
    }

    private func setup() { configureCaptureSession() }
    func start() { if cameraIsReadyToUse { session.startRunning() } }
    func stop() { session.stopRunning() }
}

extension CameraService {

    private func askUserForCameraPermission(_ completion:  ((Bool) -> Void)?) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (allowedAccess) -> Void in
            DispatchQueue.main.async { completion?(allowedAccess) }
        }
    }

    private func checkCameraAccess(completion: ((Bool) -> Void)?) {
        askUserForCameraPermission { [weak self] allowed in
            guard let self = self, let completion = completion else { return }
            self.cameraIsReadyToUse = allowed
            if allowed {
                completion(true)
            } else {
                self.showDisabledCameraAlert(completion: completion)
            }
        }
    }

    private func configureCaptureSession() {
        guard let previewView = previewView else { return }
        // Define the capture device we want to use

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No front camera available"])
            show(error: error)
            return
        }

        // Connect the camera to the capture session input
        do {

            try camera.lockForConfiguration()
            defer { camera.unlockForConfiguration() }

            if camera.isFocusModeSupported(.continuousAutoFocus) {
                camera.focusMode = .continuousAutoFocus
            }

            if camera.isExposureModeSupported(.continuousAutoExposure) {
                camera.exposureMode = .continuousAutoExposure
            }

            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)

        } catch {
            show(error: error as NSError)
            return
        }

        // Create the video data output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

        // Add the video output to the capture session
        session.addOutput(videoOutput)

        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait

        // Configure the preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = previewView.bounds
        previewView.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let outputImage = UIImage(sampleBuffer: sampleBuffer, orientation: snapshotImageOrientation) else { return }
        self.recognizeText(image: outputImage)
        
//        guard   captureCompletionBlock != nil,
//                let outputImage = UIImage(sampleBuffer: sampleBuffer, orientation: snapshotImageOrientation) else { return }
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            if let captureCompletionBlock = self.captureCompletionBlock{
//                captureCompletionBlock(outputImage)
//                AudioServicesPlayAlertSound(SystemSoundID(1108))
//            }
//            self.captureCompletionBlock = nil
//        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
    
    private func recognizeText(image: UIImage?) {
        guard let cgImage = image?.cgImage else {
            fatalError("could not get cgimage")
        }

        // Handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        // Request
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                      return
                  }

            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ",")

            let fullNameArr = text.components(separatedBy: ",")
            print(fullNameArr)
            var isResultMatch = false
            guard let arrayOfString = self.searchTextArray else {
                return
            }// ["[LTTS_SEZ_IN]", "protein"]
            print("arrayOfString ->", arrayOfString)
            for item in arrayOfString {
                isResultMatch = fullNameArr.contains(item)
                if isResultMatch {
                    print("\(Date()) : value match -> \(item) and array -> \(fullNameArr)")
//                    DispatchQueue.main.async {
//                        AudioServicesPlayAlertSound(SystemSoundID(1021))
//                    }
                    self.cameraServiceDelegate?.activityDetected(date: Date(), dateInt64: Date.currentTimeStamp, selectedItem: item)
                    break
                }
            }
            /*
            if buyResult1 || sellResult1 {
                DispatchQueue.main.async {
//                    if self?.player != nil {
//                        self?.player?.stop()
//                        self?.player = nil
//                    }
                    self?.playSound()
                }
            }
             */

        }
        // Process request
        do {
            try handler.perform([request])
        } catch {
            print (error)
        }

    }
    
    func playSoundOfSystem() {
        DispatchQueue.main.async {
            AudioServicesPlayAlertSound(SystemSoundID(1021))
        }
    }
     
    func playSound() {
        guard let url = Bundle.main.url(forResource: "jackpot", withExtension: "wav") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}


// Navigation

extension CameraService {

    private func show(alert: UIAlertController) {
        DispatchQueue.main.async {
            UIApplication.topViewController?.present(alert, animated: true, completion: nil)
        }
    }

    private func showDisabledCameraAlert(completion: ((Bool) -> Void)?) {
        let alertVC = UIAlertController(title: "Enable Camera Access",
                                        message: "Please provide access to your camera",
                                        preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { action in
            guard   let previewView = self.previewView,
                    let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(settingsUrl) else { return }
            UIApplication.shared.open(settingsUrl) { [weak self] _ in
                guard let self = self else { return }
                self.prepare(previewView: previewView,
                              cameraPosition: self.cameraPosition,
                              completion: self.preparingCompletionHandler)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completion?(false) }))
        show(alert: alertVC)
    }

    private func show(error: NSError) {
        let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil ))
        show(alert: alertVC)
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func capturePhoto(completion: ((UIImage) -> Void)?) { captureCompletionBlock = completion }
}
