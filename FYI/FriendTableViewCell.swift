//
//  FriendTableViewCell.swift
//  FYI
//
//  Created by Andrew McCalla on 12/14/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var sendFyiButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
