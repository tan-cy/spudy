//
//  FriendsViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 10/12/21.
//

import UIKit
import FirebaseDatabase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var profileRef: DatabaseReference!
    
    var allUsers: [String]!
    var alphabetizedFriendList: [String: [[String: Any]]] = [:]
    var friendList: [String] = []
    var originalFriends: [String] = []

    let cellIdentifier = "friendsTableIdentifier"
    let segueIdentifier = "friendsProfileSegueIdentifier"

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        profileRef = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
        
        getAllUsers()
        getFriends()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func getAllUsers() {
        profileRef.observe(.value) { snapshot in
            let values = snapshot.value as? NSDictionary
            self.allUsers = values?.allKeys as? [String] ?? []
        }
    }
    
    func getFriends() {
        profileRef.observe(.value) { snapshot in
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: CURRENT_USERNAME) as? NSDictionary
            
            self.originalFriends = user?[Constants.DatabaseKeys.friends] as? [String] ?? []
            // reset our data
            self.alphabetizedFriendList = [:]
            
            let group = DispatchGroup()

            // grab all friends data
            self.originalFriends.forEach({ friendID in
                group.enter()
                
                self.profileRef.child(friendID).getData() { (_, friendSnap) in
                    var friendUser = friendSnap.value as? NSDictionary
                    friendUser = friendUser?[friendID] as? NSDictionary
                    
                    let name = friendUser?["name"] as? String ?? "Unknown"
                    let photo = friendUser?["photo"] as? String ?? nil
                    
                    // create dictionary based on first letter of name
                    let letter = name.prefix(1).uppercased()
                    
                    var currentFriendsOfLetter: [[String: Any]] = self.alphabetizedFriendList[String(letter)] ?? []
                    
                    let friendObject: [String: Any] = [
                        "name": "\(name)",
                        "data": [
                            "username": friendID,
                            "photo": photo
                        ]
                    ]
                    
                    // only update friends list if this is a new change
                    if !currentFriendsOfLetter.contains(where: { item in
                        let itemData = item["data"] as! NSDictionary
                        let itemUsername = itemData["username"] as! String
                        let friendData = friendObject["data"] as! NSDictionary
                        let friendUsername = friendData["username"] as! String
                        
                        return itemUsername == friendUsername
                    }) {
                        currentFriendsOfLetter.append(friendObject)
                        
                        // sort friends within a letter in alphabetical order by name
                        currentFriendsOfLetter = currentFriendsOfLetter.sorted(by: {
                            let name1 = $0["name"] as! String
                            let name2 = $1["name"] as! String
                            return name1 < name2
                        })
                    }
                    
                    self.alphabetizedFriendList[String(letter)] = currentFriendsOfLetter
                    self.friendList.append(friendID)
                    
                    group.leave()
                }
            })
            
            group.notify(queue: .main) {
                self.tableView.reloadData()
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return alphabetizedFriendList.keys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(alphabetizedFriendList.keys).sorted(by: <)[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // need to find the number of names within a section
        let sectionName = Array(alphabetizedFriendList.keys).sorted(by: <)[section]
        // get dictionary of names under sectionName
        let peopleInSection = alphabetizedFriendList[sectionName]!
        return peopleInSection.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteFriendAlert = UIAlertController(title: "Are you sure?", message: "By deleting this friend, you will also remove yourself from their friends list.", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                
                // need to get the names within the given section
                let sectionName = Array(self.alphabetizedFriendList.keys).sorted(by: <)[indexPath.section]
                var peopleDataInSection = self.alphabetizedFriendList[sectionName]!

                let user = peopleDataInSection[indexPath.row]
                let name = user["name"] as! String
                
                let userData = user["data"] as! NSDictionary
                let username = userData["username"] as! String
                
                self.deleteOldFriends(username: username, name: name, section: sectionName, namesInSection: &peopleDataInSection, indexPath: indexPath)
            })
            
            deleteFriendAlert.addAction(deleteAction)
            deleteFriendAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(deleteFriendAlert, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // need to get the names within the given section
        let sectionName = Array(alphabetizedFriendList.keys).sorted(by: <)[indexPath.section]
        let peopleDataInSection = alphabetizedFriendList[sectionName]!
        // get the user we want within the section
        let user = peopleDataInSection[indexPath.row]
        let name = user["name"] as! String
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendsTableViewCell

        // set name
        cell.setName(name: name)
        
        // set username
        let userData = user["data"] as! NSDictionary
        let username = userData["username"] as! String
        cell.setUsername(username: username)
        
        // set profile photo
        let photoURL = userData["photo"] as? String ?? nil
        if photoURL != nil, let url = URL(string: photoURL!), let data = try? Data(contentsOf: url) {
            cell.setPhoto(photo: UIImage(data: data)!)
        } else {
            cell.setPhoto(photo: UIImage(systemName: "person.circle.fill")!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier, let destination = segue.destination as? ProfileViewController {
            // need to get the username of the person we selected
            let section = tableView.indexPathForSelectedRow!.section
            let row = tableView.indexPathForSelectedRow!.row
            
            // get the section for the person we selected
            let sectionName = Array(alphabetizedFriendList.keys).sorted(by: <)[section]
            let peopleDataInSection = alphabetizedFriendList[sectionName]!
            // get the data for the person we selected
            let userClicked = peopleDataInSection[row]
            
            let userData = userClicked["data"] as! NSDictionary
            let usernameClicked = userData["username"] as! String
            
            destination.userToGet = usernameClicked
        }
    }
    
    @IBAction func addFriendButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add a Friend", message: "You will automatically be added to this person's friends list.", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {
            (textField:UITextField!) in textField.placeholder = "Enter username"
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            (paramAction:UIAlertAction!) in
            
            if let textFieldArray = alert.textFields {
                let textFields = textFieldArray as [UITextField]
                var enteredText = textFields[0].text
                if enteredText != nil {
                    // in case the user typed in the @ sign
                    if enteredText!.prefix(1) == "@" {
                        enteredText!.removeFirst()
                    }
                    
                    // error checking
                    let badAlert = UIAlertController(title: "An error has occurred", message: "", preferredStyle: .alert)
                    badAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    if (!self.allUsers.contains(enteredText!)) {
                        badAlert.message = Constants.Messages.userNonexistent
                        self.present(badAlert, animated: true, completion: nil)
                        return
                    } else if (self.friendList.contains(enteredText!)) {
                        badAlert.message = Constants.Messages.userAlreadyFriend
                        self.present(badAlert, animated: true, completion: nil)
                        return
                        
                    } else {
                        // save friend!
                        self.saveNewFriend(newFriend: enteredText!)
                        return
                    }
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveNewFriend(newFriend: String) {
        profileRef.getData(completion: { (_, snapshot) in
            let value = snapshot.value as? NSDictionary

            // add new friend to user's list of friends
            let user = value?[CURRENT_USERNAME] as? NSDictionary
            
            var myFriends = user?[Constants.DatabaseKeys.friends] as? [String] ?? []
            myFriends.append(newFriend)
            
            self.profileRef.child(CURRENT_USERNAME).child(Constants.DatabaseKeys.friends).setValue(myFriends)
            
            // add this user to newFriend's list of friends
            let friendUser = value?[newFriend] as? NSDictionary
            
            var theirFriends = friendUser?[Constants.DatabaseKeys.friends] as? [String] ?? []
            theirFriends.append(CURRENT_USERNAME)
            
            self.profileRef.child(newFriend).child(Constants.DatabaseKeys.friends).setValue(theirFriends)
        })
    }
    
    func deleteOldFriends(username: String,
                          name: String,
                          section: String,
                          namesInSection: inout [[String: Any]],
                          indexPath: IndexPath) {
        
        tableView.beginUpdates()
        // get rid of username we want to delete from friends list
        originalFriends = originalFriends.filter {
            $0 != username
        }
        
        
        namesInSection.remove(at: indexPath.row)
        alphabetizedFriendList[section] = namesInSection
        
        if namesInSection.isEmpty {
            alphabetizedFriendList.removeValue(forKey: section)
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            tableView.deleteSections(indexSet, with: .fade)
        }

        // remove data from table
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        
        profileRef.child(CURRENT_USERNAME).child(Constants.DatabaseKeys.friends).setValue(originalFriends)
        // delete CURRENT_USER from friend's list of friends
        deleteOtherUserFriends(otherUser: username)
    }
    
    func deleteOtherUserFriends(otherUser: String) {
        profileRef.getData(completion: { (_, snapshot) in
            let value = snapshot.value as? NSDictionary

            // add new friend to user's list of friends
            let user = value?[otherUser] as? NSDictionary
            // get rid of CURRENT_USERNAME from username's friends list
            var friends = user?[Constants.DatabaseKeys.friends] as? [String] ?? []
            friends = friends.filter {
                $0 != CURRENT_USERNAME
            }
            
            self.profileRef.child(otherUser).child(Constants.DatabaseKeys.friends).setValue(friends)
        })
    }
}
