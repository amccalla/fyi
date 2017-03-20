//
//  TextViewTableViewCell.swift
//  FYI
//
//  Created by Andrew McCalla on 12/25/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.textColor = UIColor.lightGray
    }
}
