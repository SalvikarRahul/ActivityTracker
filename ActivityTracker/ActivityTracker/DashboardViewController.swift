//
//  DashboardViewController.swift
//  ActivityTracker
//
//  Created by Rahul on 04/07/24.
//

import UIKit
import Alamofire

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddActivityDelegate {
    
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var activityArray = [ActivityModel(activityName: "MODX", activities: [ "[LTTS_MODX_IN]", "[LTTS_MODX_OUT]"], isNeedToConsiderSorting: true), ActivityModel(activityName: "SEZ", activities: ["[LTTS_SEZ_IN]", "[LTTS_SEZ_OUT]"], isNeedToConsiderSorting: true)]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
        self.plusButton.layer.cornerRadius = self.plusButton.frame.height/2
        if UserDefaults.standard.value(forKey: "FirstTime") == nil {
            saveData()
            UserDefaults.standard.setValue("Write Done", forKey: "FirstTime")
        }
    }


//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.fetchCoreData { data in
//            self.activityArray = data
//            self.tableView.reloadData()
//        }
//    }

    func saveData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newData2 = Activity(context: context)
        newData2.activityName = "SEZ"
        newData2.activityIn = "[LTTS_SEZ_IN]"
        newData2.acticityOut = "[LTTS_SEZ_OUT]"
        newData2.date = Date()
        newData2.dateFormated = ""
        newData2.isNeedToConsiderSorting = false
        newData2.selectedActivity = ""

        let newData1 = Activity(context: context)
        newData1.activityName = "LTTS"
        newData1.activityIn = "[LTTS_MODX_IN]"
        newData1.acticityOut = "[LTTS_MODX_OUT]"
        newData1.date = Date()
        newData1.dateFormated = ""
        newData1.isNeedToConsiderSorting = false
        newData1.selectedActivity = ""
        

        do {
            try context.save()
        } catch {
            print("error-Saving data")
        }

    }
    
    func fetchCoreData(onSuccess: @escaping ([Activity]?) -> Void) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let items = try context.fetch(Activity.fetchRequest()) as? [Activity]
            onSuccess(items)
        } catch {
            print("error-Fetching data")
        }
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
            vc.actvityModel = sender as? ActivityModel
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

class APIFetchHandler {
    static let sharedInstance = APIFetchHandler()
   func fetchAPIData() {
      let url = "http://192.168.204.8/ActivityTracker/GetActivities";
      AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil)
        .response{ resp in
            switch resp.result{
              case .success(let data):
                do{
                  let jsonData = try JSONDecoder().decode([Model].self, from: data!)
                  print(jsonData)
               } catch {
                  print(error.localizedDescription)
               }
             case .failure(let error):
               print(error.localizedDescription)
             }
        }
   }
    
    func postAPIData(startTime: String, endTime: String) {
        let parameters: Parameters = [
            "customerID":2,
            "eventIdIn":1,
            "startTime": startTime,
            "stopTime": endTime,
            "evenT_CLOSED_BY": "USER"
        ]

       let url = "http://192.168.204.8/ActivityTracker/UpdateActivity";
       AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil)
         .response{ resp in
             switch resp.result{
               case .success(let data):
                 print(data)
              case .failure(let error):
                print(error.localizedDescription)
              }
         }
    }

}

struct Model:Codable {
   let eventID: Int
   let eventName: String
   let eventIn: String
   let eventOut: String
    let inAtive: Bool
}

