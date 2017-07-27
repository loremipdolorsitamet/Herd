//
//  PostCell.swift
//  Herd
//
//  Created by Sid Verma on 7/9/17.
//  Copyright © 2017 Herd. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var Herdmoji: UITextView!

    @IBOutlet weak var Upvote_Button: UIButton!
    @IBOutlet weak var Downvote_Button: UIButton!
    @IBOutlet weak var Timestamp: UITextView!
    @IBOutlet weak var PostBody: UITextView!
    @IBOutlet weak var Upvote_Count: UITextView!
    @IBOutlet var comments: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func Upvote_Button_Tapped(_ sender: Any) {
        
        Upvote_Button.setImage(UIImage(named:"Upvote - Selected"), for: .normal)
        Downvote_Button.setImage(UIImage(named: "Downvote"), for: .normal)
        
        guard let indexPath = self.indexPath else { return }
        print(self.indexPath?.item)
        print(indexPath.item)
        
    }
    
    @IBAction func Downvote_Button_Tapped(_ sender: Any) {
        
        Upvote_Button.setImage(UIImage(named:"Upvote"), for: .normal)
        Downvote_Button.setImage(UIImage(named: "Downvote - Selected"), for: .normal)
        
        guard let indexPath = self.indexPath else { return }
        
        print(indexPath.item)
        
    }
    

}
