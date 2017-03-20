//
//  AddFriendTableViewCell.swift
//  FYI
//
//  Created by Andrew McCalla on 12/15/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import UIKit

class AddFriendTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(isFriend: Bool) {
        if isFriend {
            addButton.setTitleColor(UIColor.white, for: .normal)
            addButton.setTitle("Added", for: .normal)
            addButton.backgroundColor = UIColor.orange
            addButton.isEnabled = false
        } else {
            addButton.setTitleColor(UIColor.orange, for: .normal)
            addButton.setTitle("Add +", for: .normal)
            addButton.backgroundColor = UIColor.white
            addButton.isEnabled = true
        }
    }
}
