//
//  CommentCell.swift
//  Herd
//
//  Created by Ethan Cox on 7/19/17.
//  Copyright © 2017 Herd. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var Herdmoji: UITextView!
    
    @IBOutlet weak var Upvote_Button: UIButton!
    @IBOutlet weak var Downvote_Button: UIButton!
    @IBOutlet weak var Timestamp: UITextView!
    @IBOutlet weak var PostBody: UITextView!
    @IBOutlet weak var Upvote_Count: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
