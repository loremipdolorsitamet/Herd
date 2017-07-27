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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHeroEnabled = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        getComments(postKey: seguedPost.postid)
    }
   
    func getComments(postKey: String) {
        let postsRef = Database.database().reference(withPath: "comments")
        postsRef.child(postKey).observeSingleEvent(of: .value, with: {(postData) in
            
            for child in postData.children {
                
                let postToAppend = post()
            
                if let child = child as? DataSnapshot {
            
                if let postDataDictionary = child.value as? [String:AnyObject] {
                    
                    if let postBody = postDataDictionary["body"] as? String {
                    
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
            }
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.commentList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
        let commentPostData = self.commentList[indexPath.item]
        
        cell.PostBody.text = commentPostData.body
        cell.Upvote_Count.text = String(commentPostData.upvote - commentPostData.downvote)
        
        cell.Upvote_Button.setImage(UIImage(named:"Upvote"), for: .normal)
        cell.Downvote_Button.setImage(UIImage(named: "Downvote"), for: .normal)
        
        if commentPostData.liked == true && commentPostData.disliked == false {
            
            cell.Upvote_Button.setImage(UIImage(named:"Upvote - Selected"), for: .normal)
            cell.Downvote_Button.setImage(UIImage(named: "Downvote"), for: .normal)
            
        } else if (commentPostData.liked == false && commentPostData.disliked == true){
            
            cell.Upvote_Button.setImage(UIImage(named:"Upvote"), for: .normal)
            cell.Downvote_Button.setImage(UIImage(named: "Downvote - Selected"), for: .normal)
            
        }
        
        /*
         
         Stylizing date is done here using SwiftDate
         SwiftDate allows us to subtract time arithmetic
         Only 2 time conditions exist, namely, either the post was made less than an hour ago or the hours ago it was posted is listed
         
         */
        
        let now = DateInRegion()
        let timeStamp = DateInRegion(string: commentPostData.timestamp, format: .iso8601(options: .withInternetDateTime), fromRegion: Region.Local())
        
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            
            return 6.5
            
        } else {
            
            return 0
        
        }
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
                let postFromArrray = commentList[indexPath.row]
                
                if postFromArrray.upvoteTapped == false {
                    
                    Database.database().reference(withPath: "comments").child(seguedPost.postid).child(postFromArrray.postid).runTransactionBlock({ (currentData : MutableData) -> TransactionResult in
                        
                        if var post = currentData.value as? [String:Any] {
                            
                            var upvote = (post["upvote"]) as! Int
                            
                            upvote+=1
                            
                            postFromArrray.liked = true
                            postFromArrray.disliked = false
                            postFromArrray.upvoteTapped = true
                            postFromArrray.downvoteTapped = false
                            
                            post["upvote"] = upvote
                            
                            currentData.value = post
                            
                            self.CommentsTableView.reloadData()
                            
                            return TransactionResult.success(withValue: currentData)
                            
                        }
                        
                        return TransactionResult.success(withValue: currentData)
                    })
                    
                }
                
            }
        }
        }
    
    @IBAction func downvoteButtonAction(_ sender: UIButton) {
        
        /*
         //Actions for down voting:
         1) Optionally unwrap indexPath of the postcell
         2) If optional unwrapping succeddes then run transactional block
         3) Transactional block runs downvoting as transaction so simulationous downvotes don't "collide"
         4)
         */
        
        if let superview = sender.superview, let cell = superview.superview as? PostCell{
            if let indexPath = tableView.indexPath(for: cell) {
                let postFromArray = commentList[indexPath.row]
                
                if postFromArray.downvoteTapped == false {
                    
                    Database.database().reference(withPath: "comments").child(seguedPost.postid).child(postFromArray.postid).runTransactionBlock({ (currentData : MutableData) -> TransactionResult in
                        
                        if var post = currentData.value as? [String:Any] {
                            
                            var downvote = (post["downvote"]) as! Int
                            
                            downvote+=1
                            
                            postFromArray.liked = false
                            postFromArray.disliked = true
                            postFromArray.downvoteTapped = true
                            postFromArray.upvoteTapped = false
                            
                            post["downvote"] = downvote
                            
                            currentData.value = post
                            
                            self.CommentsTableView.reloadData()
                            
                            return TransactionResult.success(withValue: currentData)
                            
                        }
                        
                        return TransactionResult.success(withValue: currentData)
                        })
                    }
                }
            }
        }
    }



