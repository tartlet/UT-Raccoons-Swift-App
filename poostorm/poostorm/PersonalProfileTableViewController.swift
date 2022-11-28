//
//  PersonalProfileTableViewController.swift
//  poostorm
//
//  Created by Jingsi Zhou on 11/25/22.
//

import UIKit

protocol ProfileViewControllerDelegate {
    func changeImg()
}

class PersonalProfileTableViewController: UITableViewController, PersonalProfileTableViewControllerDelegate{
    
    @IBOutlet weak var displayNameLabel: UILabel!
    var profileViewController: ProfileViewController?
    var delegate: ProfileViewControllerDelegate?
    var delegate2: UIViewController!
    var delegate4: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileViewController?.delegate3 = self
        displayNameLabel.text = displayName
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false 
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        displayNameLabel.text = displayName
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        } else {
            return 2
        }
    }
    
    func changeText() {
        self.displayNameLabel.text = displayName
    }
    
    @IBAction func changeImage(_ sender: Any) {
        if let delegate = delegate {
            delegate.changeImg()
        }
    }
    
    @IBAction func changeDisplayName(_ sender: Any) {
        let otherVC = delegate2 as! changeDisplayName
        otherVC.changeDispName()
        displayNameLabel.text = displayName
        self.viewDidLoad()
    }
    
    @IBAction func changePassword(_ sender: Any) {
        let otherVC = delegate4 as! changePassword
        otherVC.changePw()
    }
    
}
