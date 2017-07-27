//
//  Comments_View_Controller.swift
//  Herd
//
//  Created by Sid Verma on 7/25/17.
//  Copyright © 2017 Herd. All rights reserved.
//

import UIKit
import Firebase
import SwiftDate

class Comments_View_Controller: UIViewController {
    
    var seguedPost = post()
    
    @IBOutlet var PostBody: UITextView!
    
    @IBOutlet var Timestamp: UITextView!
    @IBOutlet var DownvoteButton: UIButton!
    @IBOutlet var UpvoteButton: UIButton!
    @IBOutlet var Upvotes: UITextView!
    
    @IBOutlet var commentsTableContainerView: UIView!
    
    override func viewDidLoad() {
        
        setUpMainPost() //Starts setting up the main post UI
        let barButton = UIBarButtonItem(title: "+", style: UIBarButtonItemStyle.plain, target: self, action: #selector(startSegue))
        self.navigationItem.rightBarButtonItem = barButton
        
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let commentsTableView = self.childViewControllers[0] as? CommentsTableViewController {
            
            commentsTableView.seguedPost = seguedPost
            
        }
    }
    
    func startSegue(){
        
        
       performSegue(withIdentifier: "toCommentPost", sender: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toCommentPost" {
            
            if let destinationVC = segue.destination as? CreatePostViewController {
                destinationVC.seguedPost = seguedPost
                destinationVC.fromComments = true
            }
            
        }
    }
    
    func setUpMainPost(){
        
        self.PostBody.text = seguedPost.body    //Assigns proper text
        self.Upvotes.text = String(seguedPost.upvote - seguedPost.downvote) //Assigns upvotes accordingly
        
        /*
         
         Stylizing date is done here using SwiftDate
         SwiftDate allows us to subtract time arithmetic
         Only 2 time conditions exist, namely, either the post was made less than an hour ago or the hours ago it was posted is listed
         
         */
        
        let now = DateInRegion()
        let timeStamp = DateInRegion(string: seguedPost.timestamp, format: .iso8601(options: .withInternetDateTime), fromRegion: Region.Local())
        
        let timeDifferenceHour = now.hour - (timeStamp?.hour)!
        
        if timeDifferenceHour < 1 {
            
            Timestamp.text = "< 1 hr ago"
            
        } else {
            
            Timestamp.text = (String(timeDifferenceHour) + " hrs ago")
        }

        
        if self.seguedPost.upvoteTapped {  //If the user liked the post then maintain the upvote or downvote state
            
            UpvoteButton.setImage(UIImage(named:"Upvote - Selected"), for: .normal)
            
        } else if self.seguedPost.downvoteTapped {
            
            DownvoteButton.setImage(UIImage(named: "Downvote - Selected"), for: .normal)
            
        }
        
        
        
    }

    @IBAction func upvoteTapped(_ sender: Any) {
        
        /*
         //Actions for up voting:
         1) Optionally unwrap indexPath of the postcell
         2) If optional unwrapping succeddes then run transactional block
         3) Transactional block runs downvoting as transaction so simulationous upvotes don't "collide"
         4)
         */
        
        
        if seguedPost.upvoteTapped == false {
            
            Database.database().reference(withPath: "posts").child(seguedPost.postid).runTransactionBlock({ (currentData : MutableData) -> TransactionResult in
                
                if var post = currentData.value as? [String:Any] {
                    
                    var upvote = (post["upvote"]) as! Int
                    
                    upvote+=1
                    
                    self.seguedPost.liked = true
                    self.seguedPost.disliked = false
                    self.seguedPost.upvoteTapped = true
                    self.seguedPost.downvoteTapped = false
                    
                    post["upvote"] = upvote
                    
                    currentData.value = post
                    
                    return TransactionResult.success(withValue: currentData)
                    
                }
                
                return TransactionResult.success(withValue: currentData)
            })
        
        }
    }
    
    @IBAction func downvoteTapped(_ sender: Any) {
        
        /*
         //Actions for down voting:
         1) Optionally unwrap indexPath of the postcell
         2) If optional unwrapping succeddes then run transactional block
         3) Transactional block runs downvoting as transaction so simulationous downvotes don't "collide"
         4)
         */
        
        if seguedPost.downvoteTapped == false {
            
            Database.database().reference(withPath: "posts").child(seguedPost.postid).runTransactionBlock({ (currentData : MutableData) -> TransactionResult in
                
                if var post = currentData.value as? [String:Any] {
                    
                    var downvote = (post["downvote"]) as! Int
                    
                    downvote+=1
                    
                    self.seguedPost.liked = false
                    self.seguedPost.disliked = true
                    self.seguedPost.downvoteTapped = true
                    self.seguedPost.upvoteTapped = false
                    
                    post["downvote"] = downvote
                    
                    currentData.value = post
                    
                    return TransactionResult.success(withValue: currentData)
                    
                }
                
                return TransactionResult.success(withValue: currentData)
            })
        }
        
    }


}
