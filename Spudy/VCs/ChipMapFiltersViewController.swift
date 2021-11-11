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
import MapKit

class ChipMapFiltersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    var mapFilterDelegate: MapFilterSetter!
    @IBOutlet weak var filterSegmentCtrl: UISegmentedControl!
    
    @IBOutlet weak var classesLabel: UILabel!
    @IBOutlet weak var classesCollectionView: UICollectionView!
    
    @IBOutlet weak var peopleTableView: UITableView!
    
    @IBOutlet var peopleToClassesConstraint: NSLayoutConstraint!
    @IBOutlet var peopleToSegmentCtrlConstraint: NSLayoutConstraint!
    
    let classesCellIdentifier = "currentClassesCellIdentifier"
    let peopleCellIdentifier = "peopleCellIdentifier"
    var showPeopleFilter: String! // all or classmates or friends
    
    var totalClasses: [String] = [] // all the classes
    var filterClasses: [String] = [] // classes checked
    var filterPeople: [String] = [] // people being shown
    
    var profileRef: DatabaseReference!
    var classesRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classesCollectionView.delegate = self
        classesCollectionView.dataSource = self
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        switch showPeopleFilter {
        case "Friends":
            filterSegmentCtrl.selectedSegmentIndex = 0
        case "Classmates":
            filterSegmentCtrl.selectedSegmentIndex = 1
        case "All":
            filterSegmentCtrl.selectedSegmentIndex = 2
        default:
            print("something has gone wrong in setting up filter's segment ctrl")
        }
        classesCollectionView.register(ClassesFilterCollectionViewCell.nib(), forCellWithReuseIdentifier: classesCellIdentifier)
        
        classesRef = Database.database().reference(withPath: Constants.DatabaseKeys.classesPath)
        
        // grab the data!
        profileRef = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
        profileRef.observe(.value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: CURRENT_USERNAME) as? NSDictionary
            
            // get friends for initial view
            // TODO: Change this once we implement Friends feature
            self.filterPeople = user?["friends"] as? [String] ?? []
            self.peopleTableView.reloadData()
            
            //store file in database
            let tempClasses = user?[Constants.DatabaseKeys.classes] as? [String] ?? []
            self.totalClasses.removeAll()
            self.totalClasses.append(contentsOf: tempClasses)
            
            self.classesCollectionView.reloadData()
        })
                    
        hideClassesSection()
        filterPeopleList()
        peopleTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeFilter(_ sender: Any) {
        print("you tapped \(showPeopleFilter)")
        switch filterSegmentCtrl.selectedSegmentIndex {
        case 0:
            showPeopleFilter = "Friends"
            break
        case 1:
            showPeopleFilter = "Classmates"
            break
        case 2:
            showPeopleFilter = "All"
            filterClasses = totalClasses
            break
        default:
            print("error in changing map filter")
        }
        
        mapFilterDelegate.setFilterMode(filter: showPeopleFilter)
        hideClassesSection()
        filterPeopleList()
        print("you tapped \(showPeopleFilter)")
        print("people are \(filterPeople)")
        print("classes \(filterClasses)")

        peopleTableView.reloadData()
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
    
    func filterPeopleList() {
        if showPeopleFilter == "Friends" {
            // TODO: Change once Friends feature implemented
            filterPeople.removeAll()
            filterFriends()
            
        } else if showPeopleFilter == "Classmates" {
            // create a set to not allow duplicates
            filterClassmates(classesToUse: filterClasses, completed: nil)

        } else {
            print(totalClasses)
            filterClassmates(classesToUse: totalClasses, completed: {
                self.filterFriends()
            })
            print(filterPeople)
        }
        
        self.peopleTableView.reloadData()
    }
    
    func filterFriends() {
        self.profileRef.getData(completion: { _, snapshot in

            var value = snapshot.value as? NSDictionary
            value = value?.value(forKey: CURRENT_USERNAME) as? NSDictionary
            let friendValue = value?.value(forKey: "friends") as? [String]
            var friends = Set<String>()
            friends = friends.union(friendValue ?? [])
            
                self.filterPeople = Array(friends.union(self.filterPeople))
                self.peopleTableView.reloadData()
        })
    }
    
    func filterClassmates(classesToUse: [String], completed: (() -> ())?)  {
        var classmates: Set<String> = []
        let group = DispatchGroup()
        classesToUse.forEach { removeClass in
            group.enter()
            
            self.classesRef.child(removeClass).getData(completion: {_, snapshot in
     
                var value = snapshot.value as? NSDictionary
                value = value?.value(forKey: removeClass) as? NSDictionary
                
                var students = value?.value(forKey: Constants.DatabaseKeys.students) as? [String] ?? []
                students = students.filter() {$0 != CURRENT_USERNAME}
                classmates = classmates.union(students)
                group.leave()
            })
        
        }
        group.notify(queue: .main) {
            self.filterPeople = Array(classmates)
            self.peopleTableView.reloadData()
            
            completed?()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalClasses.count
    }
    
    // shows cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: classesCellIdentifier, for: indexPath)
        let labeledCell = cell as! ClassesFilterCollectionViewCell
        labeledCell.setText(newText: totalClasses[indexPath.row])
        
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        
        if (filterClasses.contains(totalClasses[indexPath.row])) {
            (cell as! ClassesFilterCollectionViewCell).checkBox()
        }
        
        return cell
    }
    
    // if selected
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
        
        // update map with new classes
        mapFilterDelegate.setClasses(classesFilter: filterClasses)

        filterPeopleList()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterPeople.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = peopleTableView.dequeueReusableCell(withIdentifier: peopleCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = filterPeople[indexPath.row]
        return cell
    }

}
