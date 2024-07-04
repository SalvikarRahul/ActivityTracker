//
//  DashboardViewController.swift
//  ActivityTracker
//
//  Created by Rahul on 04/07/24.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddActivityDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var activityArray = [ActivityModel(activityName: "LTTS", activities: ["LTTS_SEZ_IN", "LTTS_SEZ_OUT", "LTTS_MODX_IN", "LTTS_MODX_OUT"]), ActivityModel(activityName: "GYM", activities: ["LTTS_GYM_IN", "LTTS_GYM_OUT"])]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    // MARK: TableViewDatasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardCell", for: indexPath)
        cell.textLabel?.text = activityArray[indexPath.row].activityName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activity = activityArray[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "gotoActivity", sender: activity)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ActivityViewController {
            vc.activity = sender as? ActivityModel
        }
        
        if let vc = segue.destination as? AddActivityViewController {
            vc.delegate = self
        }
    }

    @IBAction func addAction(_ sender: Any) {
        performSegue(withIdentifier: "AddActivity", sender: nil)
    }
    func addActivity(activityModel: ActivityModel) {
        activityArray.append(activityModel)
        self.tableView.reloadData()
    }

}
