//
//  AddFriendsViewController.swift
//  FYI
//
//  Created by Andrew McCalla on 12/15/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RealmSwift

class AddFriendsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var usernameTableView: UITableView!
    
    var userNames = [String]()
    var userTokens = [String: String]()
    var filtered: [String] = []
    var index = 0
    
    let realm = try! Realm()
    var profile = RealmDBUtility.sharedInstance.profileFetcher()
    
    var searchActive = false
    var db = FIRDatabase.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTableView.register(UINib(nibName: "AddFriendTableViewCell", bundle: nil), forCellReuseIdentifier: "addFriendCell")
        searchBar.delegate = self
        fetchUpdatedUsers()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindToFriendsList", sender: self)
    }
    
    
    func fetchUpdatedUsers() {
        db.observeSingleEvent(of: .value, with: { snapshot in
            self.userNames.removeAll()
            for users in snapshot.children {
                let user = users as? FIRDataSnapshot
                let dict = user?.value as? Dictionary<String, Any>
                guard let dt = dict, dt["username"] as? String != self.profile?.username else { continue }
                self.userNames.append(dt["username"]! as! String)
                self.userTokens.updateValue(dt["playerId"]! as! String, forKey: "\(dt["username"]! as! String)")
            }
        })
    }
    
    func handleTap(sender: UIButton) {
        let friendsUrl = db.ref.child("\(UserDefaults.standard.string(forKey: "playerId") ?? "")/friends")
        let newFriendUrl = friendsUrl.child("\(profile?.friends.count ?? 0)")
        let newFriendDict = ["username": "\(filtered[sender.tag])","playerId": userTokens["\(filtered[sender.tag])"]]

        newFriendUrl.setValue(newFriendDict)
        usernameTableView.reloadData()

        let addedFriend = Friend()

        if let username = newFriendDict["username"], let playerId = newFriendDict["playerId"] {
            addedFriend.username = username
            addedFriend.playerId = playerId
        }
        
        if let currentUser = profile {
            try! realm.write {
                currentUser.friends.append(addedFriend)
            }
        }
    }
}

extension AddFriendsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        
        filtered = userNames.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        if filtered.count == 0 {
            searchActive = false;
        } else {
            searchActive = true;
        }
        usernameTableView.reloadData()
    }
}

extension AddFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddFriendTableViewCell
        var alreadyFriends = false
        
        if filtered.count > 0 {
            cell.addButton.isHidden = false
            if let friends = profile?.friends, friends.count > 0 {
                for friend in friends {
                    if friend.username == filtered[indexPath.row] {
                        alreadyFriends = true
                    }
                }
            }
            cell.setupCell(isFriend: alreadyFriends)
            cell.usernameLabel.text = filtered[indexPath.row]
            cell.addButton.tag = indexPath.row
            cell.addButton.addTarget(self, action: #selector(handleTap(sender:)), for: .touchUpInside)
        } else {
            cell.usernameLabel.text = "No user found"
            cell.addButton.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filtered.count > 0 {
            return filtered.count
        } else {
            return 1
        }
    }
}
