//
//  ProfileViewController.swift
//  Spudy
//
//  Created by Lilly on 10/12/21.
//

import UIKit
import Firebase
import FirebaseDatabase

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var gradYearLabel: UILabel!
    @IBOutlet weak var contactInfoLabel: UILabel!
    @IBOutlet weak var currentClassesCollectionView: UICollectionView!
    
    let cellIdentifier = "currentClassesCellIdentifier"
    var username = "lilliantango"
    var currClasses: [String] = []
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentClassesCollectionView.delegate = self
        currentClassesCollectionView.dataSource = self
        
        // Do any additional setup after loading the view.
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        usernameLabel.text = "@\(username)"
        
        // get the user's profile info
        ref = Database.database().reference(withPath: "profile")
        ref.observe(.value, with: { snapshot in
            // grab the data!
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: self.username) as? NSDictionary
            
            // get profile photo
            let photoURLString = user?["photo"] as? String ?? nil
            if photoURLString != nil {
                if let photoURL = URL(string: photoURLString!) {
                    if let data = try? Data(contentsOf: photoURL) {
                        self.profileImage.image = UIImage(data: data)
                    }
                }
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.currentClassesCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currClasses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let labeledCell = cell as! ClassesCollectionViewCell
        labeledCell.setText(newText: currClasses[indexPath.row])
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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        if collectionView.numberOfItems(inSection: section) == 1 {
//
//            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//
//            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)
//
//        }
//
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
 
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
