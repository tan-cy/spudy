//
//  StudySpotViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 10/12/21.
//

import UIKit
import Firebase
import FirebaseDatabase


class StudySpotViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var studySpotsImage: UIImageView!
    @IBOutlet weak var studySpotsCollectionView: UICollectionView!
    @IBOutlet weak var buildingName: UILabel!
    
    let reviewSegueIdentifier = "reviewSegueIdentifier"
    
    var building = ""
    var index = 0
    var ref: DatabaseReference!
    var studySpots: [String] = []
    let textCellIdentifier = "TextCell"
    var studyDict:NSDictionary = [:]
    
    @IBAction func bookmarkTapped(_ sender: Any) {
        let bookmarkIdx = bookmarks.firstIndex(of: building)
        // remove this bookmark
        if (bookmarkIdx != nil) {
            bookmarkButton.image = UIImage(systemName: "bookmark")
            bookmarks.remove(at: bookmarkIdx!)
        } else {
            bookmarkButton.image = UIImage(systemName: "bookmark.fill")
            bookmarks.append(building)
        }
        
        ref = Database.database().reference(withPath: "\(Constants.DatabaseKeys.profilePath )/\(CURRENT_USERNAME)")
        
        let newItemRef = ref.child(Constants.DatabaseKeys.bookmarks)
        newItemRef.setValue(bookmarks)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return studySpots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: textCellIdentifier, for: indexPath) as! StudySpotsCollectionViewCell
        
        cell.label.text = studySpots[indexPath.row]
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 15
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.masksToBounds = false
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.7
        cell.layer.shadowOffset = CGSize(width:5, height:5)
        cell.layer.shadowRadius = 4
        
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        let containerWidth = studySpotsCollectionView.bounds.width
        layout.itemSize = CGSize(width:containerWidth, height:70)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        studySpotsCollectionView.collectionViewLayout = layout
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == reviewSegueIdentifier,
           let destination = segue.destination as? ReviewsViewController,
           let studySpotIndex = studySpotsCollectionView.indexPathsForSelectedItems{
            let spot = studyDict.value(forKey: studySpots[studySpotIndex[0].row]) as! NSDictionary
            destination.buildingName = buildings[index].name
            destination.spotName = studySpots[studySpotIndex[0].row]
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        studySpotsCollectionView.delegate = self
        studySpotsCollectionView.dataSource = self
        
        // Do any additional setup after loading the view.
        building = buildings[index].name
        buildingName.text = buildings[index].name
        self.studySpotsImage.image = buildings[index].image
        self.studyDict = buildings[index].studyspots as! NSDictionary
        self.studySpots = studyDict.allKeys as! [String]
        self.studySpotsCollectionView.reloadData()
        
        if (bookmarks.contains(building)) {
            bookmarkButton.image = UIImage(systemName: "bookmark.fill")
        }
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
