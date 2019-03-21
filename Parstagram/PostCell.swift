//
//  PostCell.swift
//  Parstagram
//
//  Created by Joy Paul on 3/21/19.
//  Copyright © 2019 Joy Paul. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var postTag: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
