//
//  TextTableViewCell.swift
//  FYI
//
//  Created by Andrew McCalla on 12/25/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: CustomInsetsTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
