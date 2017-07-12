//
//  Hot_or_New_Post_TableView.swift
//  Herd
//
//  Created by Sid Verma on 7/8/17.
//  Copyright © 2017 Herd. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GeoFire
import Floaty
import SwiftLocation
import CoreLocation

class Hot_or_New_Post_TableView: UITableViewController {
    
    @IBOutlet var PostTableView: UITableView!
    var returnedIndex = Int() //Current Index of Cell

    override func viewDidLoad() {
        
        getAndSetLocation()
        setUpFloatingButton()
        
        super.viewDidLoad()

        
    }
    
    func setUpFloatingButton() {
        
        //Set up floating action button
        let floaty = Floaty()
        /*
         floaty.addItem("I got a handler", icon: UIImage(named: "icon")!, handler: { item in
         let alert = UIAlertController(title: "Hey", message: "I'm hungry...", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "Me too", style: .default, handler: nil))
         self.present(alert, animated: true, completion: nil)
         floaty.sticky = true
         })
         */
        floaty.friendlyTap = true
        floaty.sticky = true
        floaty.buttonColor = UIColor.init(red: 215/255, green: 244/255, blue: 220/255, alpha: 1)
        
        self.view.addSubview(floaty)
        
    }
    
    func getAndSetLocation() {
        
        let geofireRef = Database.database().reference(withPath: "user_location")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        let uid = UserDefaults.standard.value(forKey: "uid") as! String
        
        /*
         Push users location to db
         Update user defauts current_location_lat and current_location_long
         Use the user defaults value to fire qeofire query for posts in vicinty
         */
        
        //Get location using GPS chip
        Location.getLocation(accuracy: .neighborhood, frequency: .oneShot, success: { (_, location) in
            print("Successfully pulled location:  \(location)")
            //Store Location into UserDefaults
            let defaults = UserDefaults.standard
            defaults.setValue(Double(location.coordinate.latitude), forKey: "current_location_lat")
            defaults.setValue(Double(location.coordinate.longitude), forKey: "current_location_long")
            
            //Store location in db using GeoFire with callback
            geoFire?.setLocation(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), forKey: uid) { (error) in
                if (error != nil) {
                    //Show an error message of some sorts
                    print("An error occured: \(error)")
                } else {
                    //Fire off query
                   
                }
            }

        }) { (request, last, error) in
            request.cancel() // stop continous location monitoring on error
            //Show an error message of some sorts
            print("Location monitoring failed due to an error \(error)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UITableViewCell {
    
    var indexPath: IndexPath? {
        return (superview as? UITableView)?.indexPath(for: self)
    }
}
