//
//  CommentCell.swift
//  Parstagram
//
//  Created by Joy Paul on 3/26/19.
//  Copyright © 2019 Joy Paul. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    
    @IBOutlet weak var commenterName: UILabel!
    @IBOutlet weak var commenterComment: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
