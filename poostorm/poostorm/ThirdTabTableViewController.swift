//
//  ThirdTabTableViewController.swift
//  poostorm
//
//  Created by Jingsi Zhou on 11/25/22.
//

import UIKit
import Contacts
import FirebaseAuth

public var settings = ["Profile", "Privacy & Security", "Accessibility", "Log Out"]

class ThirdTabTableViewController: UITableViewController {
    
    var row:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        print(row)
        if row == 1 {
            let shareAlert = UIAlertController(title: "Spread the Wealth!", message: "Share with:", preferredStyle: .alert)
            shareAlert.addAction(UIAlertAction(title: "Message",
                                               style: .default,
                                               handler: {_ in
                let requestContact = CNContactStore()
                requestContact.requestAccess(for: CNEntityType.contacts) {
                    result, error in
                    if error == nil {
                        print(result)
                    }
                }
                let textToShare = ["Hey! I'm stealing from the rich with this app!"]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                       activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                       // exclude some activity types from the list (optional)
                       activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
                       // present the view controller
                       self.present(activityViewController, animated: true, completion: nil)
            }))
            shareAlert.addAction(UIAlertAction(title: "Cancel",
                                               style: .cancel))
            present(shareAlert, animated: true)
        }
    }

    @IBAction func logOutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true)
        } catch {
            print("Sign out error")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileSegue" {
            let destination = segue.destination as? ProfileViewController
        }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
