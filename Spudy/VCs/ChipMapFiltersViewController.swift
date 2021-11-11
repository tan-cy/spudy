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
    var showPeopleFilter: String = "Friends"
    
    var totalClasses: [String] = []
    var filterClasses: [String] = []
    var filterPeopleKeys: [String] = []
    var filterPeopleSortedKeys: [String] = []
    var filterPeopleDict: [String: Any] = [:]
    
    var profileRef: DatabaseReference!
    var classesRef: DatabaseReference!
    
    let processClassmates = DispatchSemaphore(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classesCollectionView.delegate = self
        classesCollectionView.dataSource = self
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        
        classesCollectionView.register(ClassesFilterCollectionViewCell.nib(), forCellWithReuseIdentifier: classesCellIdentifier)
        
        classesRef = Database.database().reference(withPath: Constants.DatabaseKeys.classesPath)
        
        profileRef = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
        profileRef.observe(.value, with: { snapshot in
            // grab the data!
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: CURRENT_USERNAME) as? NSDictionary
            
            // get friends for initial view
            // TODO: Change this once we implement Friends feature
            self.filterPeopleKeys = user?["friends"] as? [String] ?? []
            self.filterPeopleKeys = self.filterPeopleKeys.sorted(by: <)
            self.getProfileData(value: value, addingFriends: true)
            self.peopleTableView.reloadData()
            
            //store file in database
            let tempClasses = user?[Constants.DatabaseKeys.classes] as? [String] ?? []
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
        filterPeopleList()
        
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
            filterPeopleKeys.removeAll()
            filterPeopleSortedKeys.removeAll()
            filterPeopleDict.removeAll()
            
            filterFriends()
            
        } else if showPeopleFilter == "Classmates" {
            filterPeopleKeys.removeAll()
            filterPeopleSortedKeys.removeAll()
            filterPeopleDict.removeAll()
            
            // create a set to not allow duplicates
            filterClassmates(classesToUse: filterClasses, completed: nil)

        } else {
            filterClassmates(classesToUse: totalClasses, completed: {
                self.filterFriends()
            })
        }
        
        self.peopleTableView.reloadData()
    }
    
    func filterFriends() {
        self.profileRef.getData(completion: { _, snapshot in

            let value = snapshot.value as? NSDictionary
            let thisValue = value?.value(forKey: CURRENT_USERNAME) as? NSDictionary

            let friendValue = thisValue?.value(forKey: "friends") as? [String]
            var friends = Set<String>()
            friends = friends.union(friendValue ?? [])
            
            self.filterPeopleKeys = Array(friends.union(self.filterPeopleKeys))
            self.filterPeopleKeys = self.filterPeopleKeys.sorted(by: <)
            self.getProfileData(value: value, addingFriends: true)
            self.peopleTableView.reloadData()
        })
    }
    
    func getProfileData(value: NSDictionary?, addingFriends: Bool) {
        
        filterPeopleKeys.forEach { person in
            let thisValue = value?.value(forKey: person) as? NSDictionary
            let name = thisValue?.value(forKey: Constants.DatabaseKeys.name) as! String
            let photo = thisValue?.value(forKey: Constants.DatabaseKeys.photo) as! String
            let longitude = thisValue?.value(forKey: Constants.DatabaseKeys.longitude) as? Double ?? Double.greatestFiniteMagnitude
            let latitude = thisValue?.value(forKey: Constants.DatabaseKeys.latitude)  as? Double ?? Double.greatestFiniteMagnitude
            
            // only add to dict if it doesn't exist yet
            if filterPeopleDict[name] == nil {
                filterPeopleDict[name] = [
                    "username": person,
                    "photo": photo,
                    "isFriend": addingFriends,
                    "longitude": longitude,
                    "latitude": latitude
                ]
            }
        }
        
        filterPeopleSortedKeys = filterPeopleDict.keys.sorted(by: <)
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
            self.filterPeopleKeys = Array(classmates)
            self.filterPeopleKeys = self.filterPeopleKeys.sorted(by: <)
            
            self.profileRef.getData(completion: {_, snapshot in
                let value = snapshot.value as? NSDictionary
                self.getProfileData(value: value, addingFriends: false)
                
                self.peopleTableView.reloadData()
                completed?()
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalClasses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: classesCellIdentifier, for: indexPath)
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
        
        filterPeopleList()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(filterPeopleKeys)
        return filterPeopleKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = peopleTableView.dequeueReusableCell(withIdentifier: peopleCellIdentifier, for: indexPath) as! MapPeopleTableViewCell
        
        // grab user's name for cell
        let name = filterPeopleSortedKeys[indexPath.row]
        cell.setName(name: name)
        
        // grab user's username for cell
        let userData = filterPeopleDict[name] as! NSDictionary
        let username = userData["username"] as! String
        cell.setUsername(username: username)
        
        // grab user's profile photo for cell
        let photoURL = userData["photo"] as? String ?? nil
        if photoURL != nil, let url = URL(string: photoURL!), let data = try? Data(contentsOf: url) {
            cell.setPhoto(photo: UIImage(data: data)!)
        } else {
            cell.setPhoto(photo: UIImage(systemName: "person.circle.fill")!)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = filterPeopleSortedKeys[indexPath.row]
        let userData = filterPeopleDict[name] as! NSDictionary
        
        let longitude = userData["longitude"] as! Double
        let latitude = userData["latitude"] as! Double
        
        // move map focusing if they are on map
        if (longitude != Double.greatestFiniteMagnitude && latitude != Double.greatestFiniteMagnitude) {
            mapFilterDelegate.focusOnUser(longitude: longitude, latitude: latitude)
            self.dismiss(animated: true, completion: nil)
            
        // just show error if they are not on the map
        } else {
            let alert = UIAlertController(title: "User Not Found", message: "This user is not sharing their location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

}
