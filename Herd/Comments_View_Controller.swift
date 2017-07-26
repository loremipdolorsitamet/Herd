//
//  Comments_View_Controller.swift
//  Herd
//
//  Created by Sid Verma on 7/25/17.
//  Copyright © 2017 Herd. All rights reserved.
//

import UIKit

class Comments_View_Controller: UIViewController {
    
    let seguedPost = post()
    
    @IBOutlet var PostBody: UITextView!
    
    @IBOutlet var Timestamp: UITextView!
    @IBOutlet var DownvoteButton: UIButton!
    @IBOutlet var UpvoteButton: UIButton!
    @IBOutlet var Upvotes: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.PostBody.text = seguedPost.body
        self.Upvotes.text = String(seguedPost.upvote - seguedPost.downvote)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func upvoteTapped(_ sender: Any) {
        
    }
    
    @IBAction func downvoteTapped(_ sender: Any) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
