//
//  ProfileViewController.swift
//  Spudy
//
//  Created by Lilly on 10/12/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreData

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var gradYearLabel: UILabel!
    @IBOutlet weak var contactInfoLabel: UILabel!
    @IBOutlet weak var currentClassesCollectionView: UICollectionView!
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    let cellIdentifier = "currentClassesCellIdentifier"
    var currClasses: [String] = []
    var ref: DatabaseReference!
    var userToGet: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentClassesCollectionView.delegate = self
        currentClassesCollectionView.dataSource = self
        
        // Do any additional setup after loading the view.
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        
        self.addFriendButton.isHidden = true
        
        usernameLabel.text = "@\(userToGet!)"
        
        // get the user's profile info
        ref = Database.database().reference(withPath: "profile")
        ref.observe(.value, with: { snapshot in
            // grab the data!
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: self.userToGet!) as? NSDictionary
            
            // get profile photo
            let photoURLString = user?["photo"] as? String ?? nil
            if photoURLString != nil,
                let photoURL = URL(string: photoURLString!),
                let data = try? Data(contentsOf: photoURL) {
                    self.profileImage.image = UIImage(data: data)
            } else {
                self.profileImage.image = UIImage(systemName: "person.circle.fill")
            }

            self.nameLabel.text = user?["name"] as? String ?? "Unknown"
            self.majorLabel.text = user?["major"] as? String ?? "Unknown"
            self.gradYearLabel.text = user?["gradYear"] as? String ?? "Unknown"
            
            let classes = user?["classes"] as? [String] ?? []
            self.currClasses.removeAll()
            self.currClasses.append(contentsOf: classes)
            
            self.contactInfoLabel.text = user?["contactInfo"] as? String ?? ""
            
            self.currentClassesCollectionView.reloadData()
            
            // now check if this person is CURRENT_USERNAME's friend or is their profile
            let currentUser = value?.value(forKey: CURRENT_USERNAME) as? NSDictionary
            var currentFriends = currentUser?["friends"] as? [String] ?? []
            
            // append CURRENT to this list so we can easily search if selected user is not CURRENT or friends
            currentFriends.append(CURRENT_USERNAME)
            // don't show add friend button if CURRENT knows this user
            if !currentFriends.contains(self.userToGet) {
                self.addFriendButton.isHidden = false
            }
        })
        self.currentClassesCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currClasses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let labeledCell = cell as! ClassesCollectionViewCell
        labeledCell.setText(newText: currClasses[indexPath.row])
        
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
      ) -> CGSize {
          let availableWidth = currentClassesCollectionView.frame.width - 20
          let widthPerItem = availableWidth / 3
        
          return CGSize(width: widthPerItem, height: 35)
      }
    
    @IBAction func addFriendPressed(_ sender: Any) {
        let friendAlert = UIAlertController(title: "Add Friend", message: "You will be automatically added to \(userToGet!)'s friends list as well.", preferredStyle: .alert)
        
        friendAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.saveNewFriend(newFriend: self.userToGet!)
        }))
        friendAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(friendAlert, animated: true, completion: nil)
    }
    
    func saveNewFriend(newFriend: String) {
        ref.getData(completion: { (_, snapshot) in
            let value = snapshot.value as? NSDictionary

            // add new friend to user's list of friends
            let user = value?[CURRENT_USERNAME] as? NSDictionary
            
            var myFriends = user?[Constants.DatabaseKeys.friends] as? [String] ?? []
            myFriends.append(newFriend)
            self.ref.child(CURRENT_USERNAME).child(Constants.DatabaseKeys.friends).setValue(myFriends)
            
            // add this user to newFriend's list of friends
            let friendUser = value?[newFriend] as? NSDictionary
            
            var theirFriends = friendUser?[Constants.DatabaseKeys.friends] as? [String] ?? []
            theirFriends.append(CURRENT_USERNAME)
            self.ref.child(newFriend).child(Constants.DatabaseKeys.friends).setValue(theirFriends)
        })
    }
    
}
