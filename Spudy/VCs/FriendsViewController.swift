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
    var alphabetizedFriendList: [String: Any] = [:]
    var friendList: [String] = []
    
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
        profileRef.observe(.value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: CURRENT_USERNAME) as? NSDictionary
            
            let friends = user?[Constants.DatabaseKeys.friends] as? [String] ?? []
            
            let group = DispatchGroup()

            // grab all friends data
            friends.forEach({ friendID in
                group.enter()
                
                self.profileRef.child(friendID).getData() { (_, friendSnap) in
                    var friendUser = friendSnap.value as? NSDictionary
                    friendUser = friendUser?[friendID] as? NSDictionary
                    
                    let name = friendUser?["name"] as? String ?? "Unknown"
                    let photo = friendUser?["photo"] as? String ?? nil
                    
                    // create dictionary based on first letter of name
                    let letter = name.prefix(1).uppercased()
                    self.alphabetizedFriendList[String(letter)] =  [
                        "\(name)": [
                            "username": friendID,
                            "photo": photo
                        ]
                    ]
                    self.friendList.append(friendID)
                    
                    group.leave()
                }
            })
            
            group.notify(queue: .main) {
                self.tableView.reloadData()
            }
        })
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
        let peopleInSection = alphabetizedFriendList[sectionName] as! [String: Any]
        return peopleInSection.keys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // need to get the names within the given section
        let sectionName = Array(alphabetizedFriendList.keys).sorted(by: <)[indexPath.section]
        let peopleDataInSection = alphabetizedFriendList[sectionName] as! [String: Any]
        // get the user we want within the section
        let name = Array(peopleDataInSection.keys).sorted(by: <)[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendsTableViewCell

        // set name
        cell.setName(name: name)
        
        // set username
        let userData = peopleDataInSection[name] as! NSDictionary
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
            let peopleDataInSection = alphabetizedFriendList[sectionName] as! [String: Any]
            // get the name for the person we selected
            let nameClicked = Array(peopleDataInSection.keys).sorted(by: <)[row]
            
            let userData = peopleDataInSection[nameClicked] as! NSDictionary
            let usernameClicked = userData["username"] as! String
            
            destination.userToGet = usernameClicked
        }
    }
    
    @IBAction func addFriendButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add a Friend", message: "Type in your friend's username.", preferredStyle: .alert)
        
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
            let user = value?[CURRENT_USERNAME] as? NSDictionary

            // add new friend to user's list of friends
            var friends = user?["friends"] as? [String] ?? []
            friends.append(newFriend)
            self.profileRef.child(CURRENT_USERNAME).child("friends").setValue(friends)
        })
    }
    

}
