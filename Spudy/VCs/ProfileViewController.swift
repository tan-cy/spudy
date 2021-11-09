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
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        })
        
        if CURRENT_USERNAME == self.userToGet {
            addFriendButton.isHidden = true
        }
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
}
