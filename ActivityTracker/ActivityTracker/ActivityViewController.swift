//
//  ActivityViewController.swift
//  ActivityTracker
//
//  Created by Rahul on 04/07/24.
//

import UIKit

class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CameraServiceDelegate {
    @IBOutlet weak var tableView: UITableView!
    var actvityModel: ActivityModel? = nil
    var cameraService = CameraService()
    let previewView = UIView(frame: .zero)
    var activitiesArray: [Activity] = []
    var timer = Timer()
    var inArray: [Activity] = []
    var outArray: [Activity] = []

    @IBOutlet weak var displayTime: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraPreviewView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.fetchCoreData() { data in
//            self.activitiesArray = data!
//        }
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
        cell.textLabel?.text = activitiesArray[indexPath.row].dateFormated
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
                guard let activityData = self?.actvityModel else {
                    return
                }
                self?.cameraService.searchTextArray = activityData.activities
                self?.cameraService.start()
            }
        }
    }
    
    func activityDetected(date: Date, selectedItem: String) {
        guard let activityObj = actvityModel else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            if activityObj.isNeedToConsiderSorting {
                if selectedItem.contains("IN") {
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

                    let newData2 = Activity(context: context)
                    newData2.activityName = activityObj.activityName
                    newData2.activityIn = activityObj.activities[0]
                    newData2.acticityOut = activityObj.activities[1]
                    newData2.date = date
                    newData2.dateFormated = "IN - " + returnCurrentDate(date: date)
                    newData2.isNeedToConsiderSorting = activityObj.isNeedToConsiderSorting
                    newData2.selectedActivity = selectedItem
                    do {
                        try context.save()
                    } catch {
                        print("error-Saving data")
                    }

                } else if selectedItem.contains("OUT"){
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let newData2 = Activity(context: context)
                    newData2.activityName = activityObj.activityName
                    newData2.activityIn = activityObj.activities[0]
                    newData2.acticityOut = activityObj.activities[1]
                    newData2.date = date
                    newData2.dateFormated = "Out - " + returnCurrentDate(date: date)
                    newData2.isNeedToConsiderSorting = activityObj.isNeedToConsiderSorting
                    newData2.selectedActivity = selectedItem
                    do {
                        try context.save()
                    } catch {
                        print("error-Saving data")
                    }

                }

            }
            self.removePreviewScreen()

        })
    }

    private func removePreviewScreen() {
        self.timer.invalidate()
        self.cameraService.stop()
        self.fetchCoreData() { data in
            self.activitiesArray = data!
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.previewView.removeFromSuperview()
            self.tableView.reloadData()
        })
        
        for value in self.activitiesArray {
            guard let val = value.selectedActivity else {return}
            if val.contains("IN") {
                inArray.append(value)
            } else {
                outArray.append(value)
            }
        }
        
        guard let inFirstObj = inArray.first?.date else {return}
        guard let outLastObj = outArray.last?.date else {return}
        let diff = Int(outLastObj.timeIntervalSince1970 - inFirstObj.timeIntervalSince1970)
        let hours = diff / 3600
        let minutes = (diff - hours * 3600) / 60
        print("\(hours):\(minutes)")
        displayTime.text = "\(hours):\(minutes)"
    }
    
    func fetchCoreData(onSuccess: @escaping ([Activity]?) -> Void) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            var items = try context.fetch(Activity.fetchRequest()) as? [Activity]
            items = items?.filter{$0.activityName == actvityModel?.activityName}
            onSuccess(items)
        } catch {
            print("error-Fetching data")
        }
    }

}
