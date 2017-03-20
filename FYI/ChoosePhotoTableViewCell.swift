//
//  ChoosePhotoTableViewCell.swift
//  FYI
//
//  Created by Andrew McCalla on 3/19/17.
//  Copyright © 2017 McCalla Apps. All rights reserved.
//

import UIKit

class ChoosePhotoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageSelected: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var controller: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imagePicker.allowsEditing = false
    }
    
    func configureChoosePhotoCell() {
        
    }
    
    @IBAction func takePhotoButtonPressed(_ sender: UIButton) {
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        controller?.show(imagePicker, sender: nil)
    }
    
    @IBAction func fromLibraryButtonPressed(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.modalPresentationStyle = .popover
        controller?.show(imagePicker, sender: nil)
    }
}

