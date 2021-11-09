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
    
    @IBOutlet weak var studySpotsImage: UIImageView!
    @IBOutlet weak var studySpotsCollectionView: UICollectionView!
    @IBOutlet weak var buildingName: UILabel!
    
    var building = ""
    var index = 0
    var ref: DatabaseReference!
    var studySpots: [String] = []
    let textCellIdentifier = "TextCell"
    

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
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        studySpotsCollectionView.delegate = self
        studySpotsCollectionView.dataSource = self
        
        // Do any additional setup after loading the view.
        buildingName.text = buildings[index].name
        self.studySpotsImage.image = buildings[index].image
        self.studySpots = buildings[index].studyspots
        self.studySpotsCollectionView.reloadData()
        
        
        
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
