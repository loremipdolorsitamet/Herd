//
//  CommentsTableViewController.swift
//  Herd
//
//  Created by Ethan Cox on 7/19/17.
//  Copyright © 2017 Herd. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GeoFire
import Floaty
import SwiftLocation
import SwiftDate
import CoreLocation
import Hero

class CommentsTableViewController: UITableViewController {
    
    @IBOutlet var CommentsTableView: UITableView!
    var returnedIndex = Int() //Current Index of Cell
    var originalCommentKey = String()
    var commentList = [post]()
    var seguedPost = post()
    //var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHeroEnabled = true
        tableView.reloadData()
        //getPost()
        //getComments()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    func getPost() {
        let postsRef = Database.database().reference(withPath: "posts")
        postsRef.observeSingleEvent(of: .childAdded, with: {(postData) in
            
            print(postData)
            
            let postToAppend = post()
            
            if let postDataDictionary = postData.value as? [String:AnyObject] {
                
                if let postBody = postDataDictionary["body"] as? String {
                    //print("postBody: " + postBody)
                    
                    if let postTime = postDataDictionary["timestamp"] as? String {
                     
                        if let postUpvote = postDataDictionary["upvote"] as? Int {
                     
                            if let postDownvote = postDataDictionary["downvote"] as? Int {
                                postToAppend.body = postBody
                                postToAppend.timestamp = postTime
                                postToAppend.upvote = postUpvote
                                postToAppend.downvote = postDownvote
                     
                                //self.commentList.append(postToAppend)
                                //print(postToAppend)
                                self.getComments(postKey: postData.key)
                     
                                self.CommentsTableView.reloadData()
                            }
                        }
                    }
                }
            }
        })
    }
    
    func getComments(postKey: String) {
        let postsRef = Database.database().reference(withPath: "posts")
        //let commentsRef = postsRef.child("comments")
        print(originalCommentKey)
        postsRef.child(postKey).child("comments").observeSingleEvent(of: .value, with: {(postData) in
            print("posts")
            print(postData)
            for child in postData.children {
                
                print("printing out snapshot")
                print(child)
                let postToAppend = post()
            
                if let postDataDictionary = postData.value as? [String:AnyObject] {
                
                    if let postBody = postDataDictionary["body"] as? String {
                        print("postBody: " + postBody)
                    
                        if let postTime = postDataDictionary["timestamp"] as? String {
                        
                            if let postUpvote = postDataDictionary["upvote"] as? Int {
                            
                                if let postDownvote = postDataDictionary["downvote"] as? Int {
                                    postToAppend.body = postBody
                                    postToAppend.timestamp = postTime
                                    postToAppend.upvote = postUpvote
                                    postToAppend.downvote = postDownvote
                                
                                    self.commentList.append(postToAppend)
                                    print(postToAppend)
                                
                                    self.CommentsTableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
        
        cell.layer.cornerRadius = 14
        cell.layer.masksToBounds = true
        let borderColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        cell.layer.borderColor = borderColor.cgColor
        cell.layer.borderWidth = 3.5
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            
            return 6.5
            
        } else {
            
            return 0
        
        }
    }

}



