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
    var friendsList: [String: Any] = [:]
//    var friendsKeysSorted: [String] = []
    let cellIdentifier = "friendsTableIdentifier"
    let segueIdentifier = "friendsProfileSegueIdentifier"

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        profileRef = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
        
        profileRef.observe(.value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: CURRENT_USERNAME) as? NSDictionary
            
            let friends = user?[Constants.DatabaseKeys.friends] as? [String] ?? []
            
            let group = DispatchGroup()

            friends.forEach({ friendID in
                
                group.enter()
                
                self.profileRef.child(friendID).getData() { (_, friendSnap) in
                    var friendUser = friendSnap.value as? NSDictionary
                    friendUser = friendUser?[friendID] as? NSDictionary
                    
                    let name = friendUser?["name"] as? String ?? "Unknown"
                    let photo = friendUser?["photo"] as? String ?? nil
                    
                    let letter = name.prefix(1)
                    self.friendsList[String(letter)] =  [
                        "\(name)": [
                            "username": friendID,
                            "photo": photo
                        ]
                        
                    ]
                    
                    group.leave()
                }
            })
            
            group.notify(queue: .main) {
//                self.friendsKeysSorted = self.friendsList.keys.sorted(by: <)
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return friendsList.keys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(friendsList.keys).sorted(by: <)[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionName = Array(friendsList.keys).sorted(by: <)[section]
        let peopleInSection = friendsList[sectionName] as! [String: Any]
        return peopleInSection.keys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionName = Array(friendsList.keys).sorted(by: <)[indexPath.section]
        let peopleDataInSection = friendsList[sectionName] as! [String: Any]
        let name = Array(peopleDataInSection.keys).sorted(by: <)[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendsTableViewCell

//        let name = friendsKeysSorted[indexPath.row]
        cell.setName(name: name)
        
        let userData = peopleDataInSection[name] as! NSDictionary
        let username = userData["username"] as! String
        cell.setUsername(username: username)
        
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
            let section = tableView.indexPathForSelectedRow!.section
            let row = tableView.indexPathForSelectedRow!.row
            
            let sectionName = Array(friendsList.keys).sorted(by: <)[section]
            let peopleDataInSection = friendsList[sectionName] as! [String: Any]
            let nameClicked = Array(peopleDataInSection.keys).sorted(by: <)[row]
            
            let userData = peopleDataInSection[nameClicked] as! NSDictionary
            let usernameClicked = userData["username"] as! String
            
            destination.userToGet = usernameClicked
        }
    }

}
