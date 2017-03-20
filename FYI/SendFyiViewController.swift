//
//  SendFyiViewController.swift
//  FYI
//
//  Created by Andrew McCalla on 12/25/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import UIKit
import OneSignal
import FirebaseStorage
import AVFoundation

class SendFyiViewController: UIViewController, UINavigationControllerDelegate {
    
    enum TextFieldTypes: Int {
        case titleTextField = 0
        case subtitleTextField
        case notifyOnTextField
    }
    
    @IBOutlet weak var fyiTableView: UITableView!
    @IBOutlet weak var sendFyiButton: UIButton!
    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let dateFormatterForBackend = DateFormatter()
    var username = [String]()
    var playerId = [String]()
    var heading = ""
    var subtitle = ""
    var message = ""
    var date = ""
    var media = ""
    var url = ""
    var counter = 0
    var audioLength = 10
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var timer = Timer()
    var image = UIImage()
    var playback = false
    
    let audioSession = AVAudioSession.sharedInstance()
    
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatLinearPCM)),
                          AVNumberOfChannelsKey : NSNumber(value: 1),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Send Fyi"
        
        fyiTableView.register(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: "text")
        fyiTableView.register(UINib(nibName: "TextViewTableViewCell", bundle: nil), forCellReuseIdentifier: "textView")
        fyiTableView.register(UINib(nibName:"CustomizeAudioTableViewCell", bundle: nil), forCellReuseIdentifier: "customizeAudio")
        fyiTableView.register(UINib(nibName: "ChoosePhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "choosePhoto")
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatterForBackend.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterForBackend.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZZ"
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: self.directoryURL() as! URL,
                                                settings: recordSettings)
            audioRecorder.prepareToRecord()
            audioRecorder.delegate = self
        } catch {
        }
    }
    
    func directoryURL() -> NSURL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("sentAudio.wav")
        return soundURL as NSURL?
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindToFriendsList", sender: self)
    }
    
    func scheduleNotification(playerId: [String], heading: String, subtitle: String, message: String, date: String) {
        OneSignal.postNotification(["contents": ["en": message], "subtitle": ["en": subtitle], "headings": ["en": heading], "include_player_ids": playerId, "content_available": "1", "send_after": "\(dateFormatterForBackend.string(from: datePicker.date))", "data": ["timestamp": date], "ios_sound": "https://firebasestorage.googleapis.com/v0/b/foryourinformation-ee9a4.appspot.com/o/sound.wav?alt=media&token=5cf9320f-a40a-4d13-96ec-ac1daf42e636", "url": "\(url)", "ios_attachments": ["id1": media]])
    }
    
    
    @IBAction func sendFyiButtonPressed(_ sender: UIBarButtonItem) {
        if username.count > 0, playerId.count > 0, message != "", date != "", heading != "" {
            scheduleNotification(playerId: playerId, heading: heading, subtitle: subtitle, message: message, date: date)
            performSegue(withIdentifier: "unwindToFriendsList", sender: self)
        } else {
            showAlertWith("Please enter at least a title, message & date", title: "Error")
        }
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        let cell = fyiTableView.cellForRow(at: NSIndexPath(row: 3, section: 0) as IndexPath) as! TextTableViewCell
        cell.textField.text = dateFormatter.string(from: sender.date)
        date = cell.textField.text ?? ""
    }
    
    func recordAudioTapped() {
        if let recorder = audioRecorder, !recorder.isRecording {
            audioRecorder.deleteRecording()
            if audioPlayer != nil {
                audioPlayer.stop()
            }
            let audioSession = AVAudioSession.sharedInstance()
            playback = true
            do {
                try audioSession.setActive(true)
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                let customizeAudioCell = fyiTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! CustomizeAudioTableViewCell
                customizeAudioCell.pauseOrPlayButton.isEnabled = true
                customizeAudioCell.pauseOrPlayButton.setImage(UIImage(named: "pauseButton"), for: .normal)
                timer.invalidate()
                counter = 0
                audioLength = 10
                updateCounterLabel()
                audioRecorder.record(forDuration: 10)
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            } catch {}
        }
    }
    
    func updateCounterLabel() {
        let customizeAudioCell = fyiTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! CustomizeAudioTableViewCell
        customizeAudioCell.counterLabel.text = String(describing: counter)
        fyiTableView.reloadData()
    }
    
    func updateCounter() {
        let customizeAudioCell = fyiTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! CustomizeAudioTableViewCell
        counter += 1
        
        if counter <= audioLength {
            if counter == audioLength {
                customizeAudioCell.pauseOrPlayButton.setImage(UIImage(named: "playButton"), for: .normal)
                fyiTableView.reloadData()
            }
            customizeAudioCell.counterLabel.text = String(describing: counter)
        }
    }
    
    func pauseOrPlayTapped() {
        if let recorder = audioRecorder, recorder.isRecording || playback {
            audioRecorder.stop()
            if audioPlayer != nil {
                audioPlayer.stop()
            }
            timer.invalidate()
            playback = false
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                let customizeAudioCell = fyiTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! CustomizeAudioTableViewCell
                try audioSession.setActive(false)
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                customizeAudioCell.pauseOrPlayButton.setImage(UIImage(named: "playButton"), for: .normal)
                fyiTableView.reloadData()
                timer.invalidate()
            } catch {
            }
        } else {
            do {
                let customizeAudioCell = fyiTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! CustomizeAudioTableViewCell
                counter = 0
                playback = true
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                customizeAudioCell.pauseOrPlayButton.setImage(UIImage(named: "pauseButton"), for: .normal)
                updateCounterLabel()
                timer.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                audioPlayer.play()
            } catch {}
        }
    }
}

extension SendFyiViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0:
                return configureTextCell(indexPath: indexPath)
            case 1:
                return configureTextCell(indexPath: indexPath)
            case 2:
                return configureTextViewCell(indexPath: indexPath)
            case 3:
                return configureTextCell(indexPath: indexPath)
            case 4:
                return configureTextViewCell(indexPath: indexPath)
            case 5:
                return configureCustomizeAudioCell(indexPath: indexPath)
            case 6:
                return configureChoosePhototCell(indexPath: indexPath)
            default:
                break
        }
        return UITableViewCell()
    }
    
    func configureChoosePhototCell(indexPath: IndexPath) -> UITableViewCell {
        let choosePhotoCell = fyiTableView.dequeueReusableCell(withIdentifier: "choosePhoto", for: indexPath) as! ChoosePhotoTableViewCell
        choosePhotoCell.controller = self
        choosePhotoCell.imagePicker.delegate = self
        choosePhotoCell.imageSelected.image = image
        return choosePhotoCell
    }
    
    func configureCustomizeAudioCell(indexPath: IndexPath) -> UITableViewCell {
        let customizeAudioCell = fyiTableView.dequeueReusableCell(withIdentifier: "customizeAudio", for: indexPath) as! CustomizeAudioTableViewCell
        
        customizeAudioCell.recordButton.addTarget(self, action: #selector(recordAudioTapped), for: .touchUpInside)
        customizeAudioCell.pauseOrPlayButton.addTarget(self, action: #selector(pauseOrPlayTapped), for: .touchUpInside)
        return customizeAudioCell
    }
    
    func configureTextViewCell(indexPath: IndexPath) -> UITableViewCell {
        let textViewCell = fyiTableView.dequeueReusableCell(withIdentifier: "textView", for: indexPath) as! TextViewTableViewCell

        switch indexPath.row {
            case 2:
                textViewCell.label.text = "Message"
                textViewCell.textView.delegate = self
            
            case 4:
                textViewCell.label.text = "Sending To"
                textViewCell.textView.isUserInteractionEnabled = false
                textViewCell.textView.textColor = .darkGray
                textViewCell.textView.text = constructStringFromArray(stringArray: username)

            default:
                break
        }
        return textViewCell
    }
    
    func configureTextCell(indexPath: IndexPath) -> UITableViewCell {
        let textCell = fyiTableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextTableViewCell
        textCell.textField.delegate = self
        textCell.textField.placeholder = "..."

        switch indexPath.row {
            case 0:
                textCell.label.text = "Title"
                textCell.textField.text = heading
                textCell.textField.tag = TextFieldTypes.titleTextField.rawValue
            
            case 1:
                textCell.label.text = "Subtitle"
                textCell.textField.text = subtitle
                textCell.textField.tag = TextFieldTypes.subtitleTextField.rawValue
            
            case 3:
                textCell.label.text = "Notify on"
                textCell.textField.tag = TextFieldTypes.notifyOnTextField.rawValue
                textCell.textField.inputView = datePicker
                datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
                textCell.textField.text = date
            
            default:
                break
        }
        return textCell
    }
    
    func constructStringFromArray(stringArray: [String]) -> String {
        var constructedString = ""
        for index in 0..<stringArray.count {
            if index == stringArray.count - 1 {
                constructedString += "\(stringArray[index])"
            } else {
                constructedString += "\(stringArray[index]), "
            }
        }
        return constructedString
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 || indexPath.row == 4 {
            return 120
        } else if indexPath.row == 5 {
            return 86
        } else  if indexPath.row == 6 {
            return 112
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
}

extension SendFyiViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == TextFieldTypes.notifyOnTextField.rawValue {
            textField.text = dateFormatter.string(from: datePicker.date)
            date = textField.text ?? ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case TextFieldTypes.titleTextField.rawValue:
            heading = textField.text ?? ""
            textField.text = heading
            
        case TextFieldTypes.subtitleTextField.rawValue:
            subtitle = textField.text ?? ""
            textField.text = subtitle
            
        case TextFieldTypes.notifyOnTextField.rawValue:
            textField.text = dateFormatter.string(from: datePicker.date)
            date = textField.text ?? ""
            
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length

        switch textField.tag {
        case TextFieldTypes.titleTextField.rawValue:
            heading = textField.text ?? ""
            return checkCharacterCount(newLength: newLength, limitLength: 36)
            
        case TextFieldTypes.subtitleTextField.rawValue:
            subtitle = textField.text ?? ""
            return checkCharacterCount(newLength: newLength, limitLength: 24)
            
        default:
            break
        }
        return true
    }
    
    func checkCharacterCount(newLength: Int, limitLength: Int) -> Bool {
        return newLength <= limitLength
    }
}

extension SendFyiViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.characters.count > 0 {
            textView.textColor = UIColor.darkGray
        } else {
            textView.textColor = UIColor.lightGray
        }
        message = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textViewText = textView.text else { return true }
        let newLength = textViewText.characters.count + text.characters.count - range.length
        return checkCharacterCount(newLength: newLength, limitLength: 140)
    }
}

extension SendFyiViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let recorderUrl = String(describing: recorder.url)
        let customizeAudioCell = fyiTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! CustomizeAudioTableViewCell
        customizeAudioCell.pauseOrPlayButton.setImage(UIImage(named: "playButton"), for: .normal)
        timer.invalidate()
        audioLength = counter
        media = recorderUrl
        uploadAudio(filePath: media, contentType: "sentAudio.wav")
    }
    
    func uploadAudio(filePath: String, contentType: String) {
        let localFile = URL(string: filePath)!
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let mediaRef = storageRef.child("\(UserDefaults.standard.value(forKey: "playerId") as! String)/\(contentType)")
        
        let uploadTask = mediaRef.putFile(localFile, metadata: nil) { metadata, error in
            if let error = error {
                self.showAlertWith("Unable to send media within your notification at this time", title: "Upload Media Error")
            } else {
                guard let url = metadata?.downloadURL()?.absoluteString else { return }
                self.media = url + "?filetype=" + contentType
            }
        }
    }
    
    func uploadPhoto(imagePicked: UIImage) {
        let storageRef = FIRStorage.storage().reference().child("\(UserDefaults.standard.value(forKey: "playerId") as! String)/sentImage.jpg")
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        
        if let uploadData = UIImageJPEGRepresentation(imagePicked, 1.0) {
            storageRef.put(uploadData, metadata: metaData, completion: { (metadata, error) in
                if error != nil {
                    self.showAlertWith("Unable to send photo within notifications at this time", title: "Upload Photo Error")
                    return
                } else {
                    guard let url = metadata?.downloadURL()?.absoluteString else { return }
                    self.media = url + "?filetype=sentImage.jpg"
                }
            })
        }
    }
}

extension SendFyiViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = pickedImage
            dismiss(animated: true, completion: nil)
            uploadPhoto(imagePicked: image)
            fyiTableView.reloadData()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
