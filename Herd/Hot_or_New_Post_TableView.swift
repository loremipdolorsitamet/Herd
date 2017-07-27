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
    var indexPathForSegue = Int()

    override func viewDidLoad() {
        
        //All UI based operations are done in response to data recieved in this method
        //fakePostTest()
        let geoFireRef = "user_location"
        getAndSetLocation(reference: geoFireRef)
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh), for: UIControlEvents.valueChanged)
        
        super.viewDidLoad()

        
    }
    
    func handleRefresh() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func fakePostTest() {
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
    }
    
    func getPosts(center: CLLocation) {
        
        let geofireRef = Database.database().reference(withPath: "post_location/")
        let postRef = Database.database().reference(withPath: "posts")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        
        var circleQuery = geoFire?.query(at: center, withRadius: 10.0)
        
        var circleQueryHandler = circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            
            let rightNow = DateInRegion()
            
            let rightNowMinus12InInternetTime = (rightNow - 24.hours).string(format: .iso8601(options: [.withInternetDateTime]))
            
            postRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: rightNow.string(format: .iso8601(options: [.withInternetDateTime]))).queryStarting(atValue: rightNowMinus12InInternetTime).observeSingleEvent(of: .value, with: {(postData) in
                
                //print(postData.value)
                
                let postToAppend = post()
                
                if let postDataDictionary = postData.value as? [String:AnyObject] {
                    
                    if let postBody = postDataDictionary[key]?["body"] as? String {
    
                        if let postTime = postDataDictionary[key]?["timestamp"] as? String {

                            if let postUpvote = postDataDictionary[key]?["upvote"] as? Int {

                                if let postDownvote = postDataDictionary[key]?["downvote"] as? Int {
                                    
                                    if let postCommentCount = postDataDictionary[key]?["commentCount"] as? Int {
                                
                                    postToAppend.body = postBody
                                    postToAppend.timestamp = postTime
                                    postToAppend.upvote = postUpvote
                                    postToAppend.downvote = postDownvote
                                    postToAppend.delta = postUpvote - postDownvote
                                    postToAppend.postid = key
                                    postToAppend.commentsCount = postCommentCount
                                    
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
                    
                }
            })
            
            
        })
        
        
    }

    func getAndSetLocation(reference : String) {
        
        let geofireRef = Database.database().reference(withPath: reference)
        let geoFire = GeoFire(firebaseRef: geofireRef)
        let uid = UserDefaults.standard.value(forKey: "uid") as! String
        
        /*
         Push users location to db
         Update user defauts current_location_lat and current_location_long
         Use the user defaults value to fire qeofire query for posts in vicinty
         */
        
        //Get location using GPS chip
        Location.getLocation(accuracy: .neighborhood, frequency: .oneShot, success: { (_, location) in
            
            //Store Location into UserDefaults
            var schoolLocationKeys = [String]()
            let defaults = UserDefaults.standard
            defaults.setValue(Double(location.coordinate.latitude), forKey: "current_location_lat")
            defaults.setValue(Double(location.coordinate.longitude), forKey: "current_location_long")
            
            //Store location in db using GeoFire with callback
            geoFire?.setLocation(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), forKey: uid) { (error) in
                if (error != nil) {
                    //Show an error message of some sorts
                    print("An error occured: \(error)")
                } else {
                    
                    let schoolsGeoFireRef = Database.database().reference(withPath: "school_location")
                    let schoolsGeoFire = GeoFire(firebaseRef: schoolsGeoFireRef)
                    
                    var schoolsCircleQuery = schoolsGeoFire?.query(at: location, withRadius: 0.05)
                    
                    var schoolsCircleQueryHandler = schoolsCircleQuery?.observe(.keyEntered, with: {(key: String!, location: CLLocation!) in
                        
                        print(key)
                        schoolLocationKeys.append(key)

                    })
                    schoolsCircleQuery?.observeReady({
                        
                        if schoolLocationKeys.count == 0 {      //if no schools are in the vicinty
                            
                            print("Querying posts")
                            self.getPosts(center: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                            
                        } else {
                            
                            //Show error
                        }
                        
                    })
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
        
        /*
         
         Switch to control which data is inside the table view 
         Note: While the data stays the same, it is sorted differently 
         Index 0 means hot is selected, index 1 means new is selected
         
         postList.delta is the number of upvotes 
         postList.timstamp provides the internet time of post which is then parsed inside the tableview cell 
         
         */
        
        if hotOrNewSwitch.selectedSegmentIndex == 0 {
            
            //reorder by upvotes
            postList.sort(by: {($0.upvote - $0.downvote) > ($1.upvote - $1.downvote)})
            tableView.reloadData()
            
            
        } else {
            
            //reorder by timestamp
            postList.sort(by: { $0.timestamp  > $1.timestamp })
            tableView.reloadData()
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        //postList.sort(by: {($0.upvote - $0.downvote) > ($1.upvote - $1.downvote)}) //Sorts array based off of upvotes
        
        if hotOrNewSwitch.selectedSegmentIndex == 0 {
            
            //reorder by upvotes
            postList.sort(by: {($0.upvote - $0.downvote) > ($1.upvote - $1.downvote)})
            
            
        } else {
            
            //reorder by timestamp
            postList.sort(by: { $0.timestamp  > $1.timestamp })
            
        }
        
        //Convenience variable for interacting with posts
        let postData = self.postList[indexPath.item]
        
        
        cell.PostBody.text = postData.body
        cell.Upvote_Count.text = String(postData.upvote - postData.downvote)
        
        /*
         
         Logic for setting upvote or downvote button, controlled first by user's interaction the programmtically set in upvote/downvote button action
         
         */
        
        cell.Upvote_Button.setImage(UIImage(named:"Upvote"), for: .normal)
        cell.Downvote_Button.setImage(UIImage(named: "Downvote"), for: .normal)
        
        if postData.liked == true && postData.disliked == false {
            
            cell.Upvote_Button.setImage(UIImage(named:"Upvote - Selected"), for: .normal)
            cell.Downvote_Button.setImage(UIImage(named: "Downvote"), for: .normal)
            
        } else if (postData.liked == false && postData.disliked == true){
            
            cell.Upvote_Button.setImage(UIImage(named:"Upvote"), for: .normal)
            cell.Downvote_Button.setImage(UIImage(named: "Downvote - Selected"), for: .normal)
            
        }
        
        
        /*
         
         Stylizing date is done here using SwiftDate 
         SwiftDate allows us to subtract time arithmetic 
         Only 2 time conditions exist, namely, either the post was made less than an hour ago or the hours ago it was posted is listed
         
         */
        
        let now = DateInRegion()
        let timeStamp = DateInRegion(string: postData.timestamp, format: .iso8601(options: .withInternetDateTime), fromRegion: Region.Local())
        
        let timeDifferenceHour = now.hour - (timeStamp?.hour)!
        
        if timeDifferenceHour < 1 {
            
            cell.Timestamp.text = "< 1 hr ago"
            
        } else {
            
            cell.Timestamp.text = (String(timeDifferenceHour) + " hrs ago")
        }
        
        cell.layer.cornerRadius = 14
        cell.layer.masksToBounds = true
        let borderColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        cell.layer.borderColor = borderColor.cgColor
        cell.layer.borderWidth = 3.5
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @IBAction func upvoteButtonAction(_ sender: UIButton) {
        
        /*
         //Actions for up voting:
         1) Optionally unwrap indexPath of the postcell
         2) If optional unwrapping succeddes then run transactional block
         3) Transactional block runs downvoting as transaction so simulationous upvotes don't "collide"
         4)
         */
        
        
        if let superview = sender.superview, let cell = superview.superview as? PostCell{
            if let indexPath = tableView.indexPath(for: cell) {
                let postFromArrray = postList[indexPath.row]
                
                if postFromArrray.upvoteTapped == false {
                
                Database.database().reference(withPath: "posts").child(postFromArrray.postid).runTransactionBlock({ (currentData : MutableData) -> TransactionResult in
                    
                    if var post = currentData.value as? [String:Any] {
                        
                        var upvote = (post["upvote"]) as! Int
                        
                            upvote+=1

                            postFromArrray.liked = true
                            postFromArrray.disliked = false
                            postFromArrray.upvoteTapped = true
                            postFromArrray.downvoteTapped = false
                        
                            post["upvote"] = upvote
                        
                            currentData.value = post
                        
                            self.tableView.reloadData()
                        
                            return TransactionResult.success(withValue: currentData)
                        
                        }
                    
                        return TransactionResult.success(withValue: currentData)
                    })
                    
                }
                
            }
        }   
    }
    
    @IBAction func downButtonAction(_ sender: UIButton) {
        
        /*
        //Actions for down voting: 
         1) Optionally unwrap indexPath of the postcell 
         2) If optional unwrapping succeddes then run transactional block
         3) Transactional block runs downvoting as transaction so simulationous downvotes don't "collide" 
         4)
        */
        
        if let superview = sender.superview, let cell = superview.superview as? PostCell{
            if let indexPath = tableView.indexPath(for: cell) {
                let postFromArray = postList[indexPath.row]
                
                if postFromArray.downvoteTapped == false {
                
                Database.database().reference(withPath: "posts").child(postFromArray.postid).runTransactionBlock({ (currentData : MutableData) -> TransactionResult in

                    if var post = currentData.value as? [String:Any] {
                        
                            var downvote = (post["downvote"]) as! Int
                        
                            downvote+=1
                        
                            postFromArray.liked = false
                            postFromArray.disliked = true
                            postFromArray.downvoteTapped = true
                            postFromArray.upvoteTapped = false
                        
                            post["downvote"] = downvote
                        
                            currentData.value = post
                        
                            self.tableView.reloadData()
                        
                            return TransactionResult.success(withValue: currentData)
                        
                        }
                    
                        return TransactionResult.success(withValue: currentData)
                    })
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath.item)
        
        self.indexPathForSegue = indexPath.item
        performSegue(withIdentifier: "toCommentsView", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCommentsView" {
            
            print(self.indexPathForSegue)
           if let destinationVC = segue.destination as? Comments_View_Controller {
                    destinationVC.seguedPost = postList[self.indexPathForSegue]

            
            }
            
            //CommentsTableViewController
            
        }
    }

    


}

extension UITableViewCell {
    
    var indexPath: IndexPath? {
        return (superview as? UITableView)?.indexPath(for: self)
    }
}
