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
import SwiftDate
import CoreLocation
import Fakery

class Hot_or_New_Post_TableView: UITableViewController {
    
    @IBOutlet weak var hotOrNewSwitch: UISegmentedControl!
    @IBOutlet var PostTableView: UITableView!
    var returnedIndex = Int() //Current Index of Cell
    var postList = [post]()
    let faker = Faker()

    override func viewDidLoad() {
        
        getAndSetLocation()
        
        //fakePostTest()
        
        super.viewDidLoad()

        
    }
    
   /* func fakePostTest() {
        if let locationLat = UserDefaults.standard.value(forKey: "current_location_lat") as? Double {
            if let locationLong = UserDefaults.standard.value(forKey: "current_location_long") as? Double {
                if let uid = UserDefaults.standard.value(forKey: "uid") as? String {
                    for i in 0...200 {
                    //Get current time
                    let now = DateInRegion()
                    let nowInternetDateTime = now.string(format: .iso8601(options: [.withInternetDateTime])) //Looks like this: 2017-07-18T16:12:53-07:00
                    
                    //Generated random post id and ref
                    let postRef = Database.database().reference(withPath: "posts/").childByAutoId()
                    let postUID = postRef.key
                    
                    //Post body text
                    let postBodyText = faker.lorem.characters(amount: 200)
                    
                    //Geofire Reference
                    let geofireRef = Database.database().reference(withPath: "post_location/")
                    let geoFire = GeoFire(firebaseRef: geofireRef)
                    
                    //User Reference
                    let userRef = Database.database().reference(withPath: "users/").child(uid).child("posts")
                    
                    geoFire?.setLocation(CLLocation(latitude: locationLat, longitude: locationLong), forKey: postUID) { (error) in
                        if (error != nil) {
                            //Show an error message of some sorts
                            print("An error occured: \(error)")
                        } else {
                            
                            //Now that the post location is set let's write the post body to the post ref and to the users ref
                            
                            postRef.setValue(["body" : postBodyText,
                                              "timestamp" : nowInternetDateTime,
                                              "upvote" : 0,
                                              "downvote" : 0])
                            
                            userRef.updateChildValues([postUID:true])
                            
                            
                            }
                 
                        }
                    }
                }
            }
        }
    } */
    
    func getPosts(center: CLLocation) {
        
        let geofireRef = Database.database().reference(withPath: "post_location/")
        let postRef = Database.database().reference(withPath: "posts")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        
        var circleQuery = geoFire?.query(at: center, withRadius: 200.0)
        
        var circleQueryHandler = circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            
            let rightNow = DateInRegion()
            
            let rightNowMinus12InInternetTime = (rightNow - 24.hours).string(format: .iso8601(options: [.withInternetDateTime]))
            
            postRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: rightNow.string(format: .iso8601(options: [.withInternetDateTime]))).queryStarting(atValue: rightNowMinus12InInternetTime).observeSingleEvent(of: .value, with: {(postData) in
                
               // print(postData.value)
                
                let postToAppend = post()
                
                if let postDataDictionary = postData.value as? [String:AnyObject] {
                    
                    if let postBody = postDataDictionary[key]?["body"] as? String {
    
                        if let postTime = postDataDictionary[key]?["timestamp"] as? String {

                            if let postUpvote = postDataDictionary[key]?["upvote"] as? Int {

                                if let postDownvote = postDataDictionary[key]?["downvote"] as? Int {
                                
                                    postToAppend.body = postBody
                                    postToAppend.timestamp = postTime
                                    postToAppend.upvote = postUpvote
                                    postToAppend.downvote = postDownvote
                                    postToAppend.delta = postUpvote - postDownvote
                                    
                                    if !self.postList.contains(postToAppend) {
                                    
                                        self.postList.append(postToAppend)
                                    
                                        self.PostTableView.reloadData()
                                        
                                    }
                                    
                                    //Attach observers to upvote
                                    postRef.child(key).observe(.childChanged, with: {(changedVal) in
                                        if changedVal.key == "upvote" {
                                            
                                            if let upvoteInt = changedVal.value as? Int {
                                                
                                                postToAppend.upvote = upvoteInt
                                                
                                                self.PostTableView.reloadData()
                                            }
                                            
                                        } else if changedVal.key == "downvote" {
                                            
                                            if let downvoteInt = changedVal.value as? Int {
                                                
                                                postToAppend.downvote = downvoteInt
                                                self.PostTableView.reloadData()
                                            }
                                            
                                        }
                                    })
                                }
                                
                            }
                            
                        }
                        
                    }
   
                }
                
            })
            
            
        })
        
        
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
                    self.getPosts(center: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                   //Fire off query
                }
            }

        }) { (request, last, error) in
            request.cancel() // stop continous location monitoring on error
            //Show an error message of some sorts
            print("Location monitoring failed due to an error \(error)")
        }
        
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.postList.count
    }
    
    
    @IBAction func hotOrNewSwitchAction(_ sender: Any) {
        
        let tempPostList = postList
        
        if hotOrNewSwitch.selectedSegmentIndex == 0 {
            
            //reorder by upvotes
            postList.sort(by: {$0.delta > $1.delta})
            tableView.reloadData()
            
            
        } else {
            
            //reorder by timestamp
            postList.sort(by: { $0.timestamp  < $1.timestamp })
            tableView.reloadData()
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
       // if indexPath.item % 23 == 0 {
        //    tableView.reloadData()
       // }
        
        
        
        let postData = self.postList.reversed()[indexPath.item]
        
        cell.PostBody.text = postData.body
        cell.Upvote_Count.text = String(postData.upvote - postData.downvote)
        
        //Timestamp formatting 
        let now = DateInRegion()
        let timeStamp = DateInRegion(string: postData.timestamp, format: .iso8601(options: .withInternetDateTime), fromRegion: Region.Local())
        
        let timeDifferenceHour = now.hour - (timeStamp?.hour)!
        
        if timeDifferenceHour < 1 {
            
            cell.Timestamp.text = "< 1 hr ago"
            
        } else {
            
            cell.Timestamp.text = (String(timeDifferenceHour) + " hrs ago")
        }
        
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
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
