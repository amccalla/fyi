//
//  FriendsListViewController.swift
//  FYI
//
//  Created by Andrew McCalla on 12/14/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import OneSignal
import RealmSwift
import ObjectMapper

class FriendsListViewController: UIViewController {

    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var sendFyiButton: UIBarButtonItem!
    
    var searchCellSelected = false
    var profile = RealmDBUtility.sharedInstance.profileFetcher()
    var usernameSelected = [String]()
    var playerIdSelected = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "friendCell")
        navigationItem.hidesBackButton = true
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        friendsTableView.reloadData()
    }
    
    @IBAction func unwindToFriendsList(segue: UIStoryboardSegue) {
        
    }
    
    func updateButtonImage(button: UIButton) {
        if button.currentImage?.isEqual(UIImage(named: "uncheckedBox")) == true {
            sendFyiButton.isEnabled = true
            button.setImage(UIImage(named: "checkedBox"), for: .normal)
        } else {
            button.setImage(UIImage(named: "uncheckedBox"), for: .normal)
        }
    }
    
    func handleTapForButton(sender: UIButton) {
        updateButtonImage(button: sender)
        handleRecipientList(index: sender.tag)
    }
    
    func handleRecipientList(index: Int) {
        if let username = profile?.friends[index].username, let playerId = profile?.friends[index].playerId {
            if !usernameSelected.contains(username) && !playerIdSelected.contains(playerId) {
                usernameSelected.append(username)
                playerIdSelected.append(playerId)
            } else {
                usernameSelected = usernameSelected.filter{$0 != username}
                playerIdSelected = playerIdSelected.filter{$0 != playerId}
            }
            
            if usernameSelected.count == 0 || playerIdSelected.count == 0 {
                sendFyiButton.isEnabled = false
            }
        } else {
            showAlertWith("There was an issue fetching the user. Please try again later", title: "Error")
        }

    }
    
    func handleTapGesture(sender: UITapGestureRecognizer) {
        if let view = sender.view as? UILabel {
            let cell = friendsTableView.cellForRow(at: NSIndexPath(row: view.tag, section: 0) as IndexPath) as! FriendTableViewCell
            updateButtonImage(button: cell.sendFyiButton)
            handleRecipientList(index: view.tag)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? SendFyiViewController
        vc?.username = usernameSelected
        vc?.playerId = playerIdSelected
    }
}

extension FriendsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(sender:)))
        
        cell.usernameLabel.tag = indexPath.row
        cell.sendFyiButton.tag = indexPath.row
        cell.usernameLabel.text = profile?.friends[indexPath.row].username
        cell.sendFyiButton.addTarget(self, action: #selector(handleTapForButton(sender:)), for: .touchUpInside)
        cell.usernameLabel.addGestureRecognizer(tapGesture)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profile?.friends.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
