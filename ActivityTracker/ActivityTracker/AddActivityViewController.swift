//
//  AddActivityViewController.swift
//  ActivityTracker
//
//  Created by Rahul on 04/07/24.
//

import UIKit

protocol AddActivityDelegate: AnyObject {
    func addActivity(activityModel: ActivityModel)
}

class AddActivityViewController: UIViewController {

    @IBOutlet weak var searchText: UITextField!		
    @IBOutlet weak var activityName: UITextField!
    weak var delegate: AddActivityDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func SaveButtonAction(_ sender: Any) {
        guard let activityName = activityName.text else {return}
        guard let activitySearch = searchText.text else {return}
        delegate?.addActivity(activityModel: ActivityModel(activityName: activityName, activities: [activitySearch]))
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
