//
//  ChipMapFiltersViewController.swift
//  Spudy
//
//  Created by Cindy Tan on 11/1/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreData

class ChipMapFiltersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var mapFilterDelegate: MapFilterSetter!
    @IBOutlet weak var filterSegmentCtrl: UISegmentedControl!
    
    @IBOutlet weak var classesLabel: UILabel!
    @IBOutlet weak var classesCollectionView: UICollectionView!
    
    @IBOutlet var peopleToClassesConstraint: NSLayoutConstraint!
    @IBOutlet var peopleToSegmentCtrlConstraint: NSLayoutConstraint!
    
    let cellIdentifier = "currentClassesCellIdentifier"
    var showPeopleFilter: String = "Friends"
    var totalClasses: [String] = []
    var filterClasses: [String] = []
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classesCollectionView.delegate = self
        classesCollectionView.dataSource = self
        
        classesCollectionView.register(ClassesFilterCollectionViewCell.nib(), forCellWithReuseIdentifier: cellIdentifier)
        
        CURRENT_USER = "lilliantango"
        
        ref = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
        ref.observe(.value, with: { snapshot in
            // grab the data!
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: CURRENT_USER) as? NSDictionary
            
            //store file in database
            let tempClasses = user?["classes"] as? [String] ?? []
            self.totalClasses.removeAll()
            self.totalClasses.append(contentsOf: tempClasses)
            
            self.classesCollectionView.reloadData()
        })
                    
        hideClassesSection()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeFilter(_ sender: Any) {
        switch filterSegmentCtrl.selectedSegmentIndex {
        case 0:
            showPeopleFilter = "Friends"
        case 1:
            showPeopleFilter = "Classmates"
        case 2:
            showPeopleFilter = "All"
        default:
            showPeopleFilter = "Friends"
        }
        
        hideClassesSection()
    }
    
    func hideClassesSection() {
        if showPeopleFilter == "Classmates" {
            classesLabel.isHidden = false
            classesCollectionView.isHidden = false
            
            peopleToClassesConstraint.isActive = true
            peopleToSegmentCtrlConstraint.isActive = false
        } else {
            classesLabel.isHidden = true
            classesCollectionView.isHidden = true
            
            peopleToClassesConstraint.isActive = false
            peopleToSegmentCtrlConstraint.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalClasses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let labeledCell = cell as! ClassesFilterCollectionViewCell
        labeledCell.setText(newText: totalClasses[indexPath.row])
        
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ClassesFilterCollectionViewCell
        cell.checkBox()
        
        // now see if we need to start filtering with this class
        if cell.getCheckedStatus() {
            // user wants to filter using this
            filterClasses.append(cell.getText())
        } else {
            // don't want to filter using this anymore
            filterClasses = filterClasses.filter() {$0 != cell.getText()}
        }
        
        print(filterClasses)
    }

}
