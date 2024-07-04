//
//  ActivityViewController.swift
//  ActivityTracker
//
//  Created by Rahul on 04/07/24.
//

import UIKit

class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CameraServiceDelegate {
    @IBOutlet weak var tableView: UITableView!
    var activity: ActivityModel? = nil
    var cameraService = CameraService()
    let previewView = UIView(frame: .zero)
    var activitiesArray: [String] = []
    var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraPreviewView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraService.start()
        cameraService.cameraServiceDelegate = self
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    }
    @objc func timerAction(){
        self.removePreviewScreen()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activitiesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordData", for: indexPath)
        cell.textLabel?.text = activitiesArray[indexPath.row]
        return cell
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
            if success {
                guard let activityData = self?.activity?.activities else {
                    return
                }
                self?.cameraService.searchTextArray = activityData
                self?.cameraService.start()
            }
        }
    }
    
    func activityDetected() {
        removePreviewScreen()
    }

    private func removePreviewScreen() {
        self.timer.invalidate()
        self.cameraService.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.previewView.removeFromSuperview()
        })
    }
}