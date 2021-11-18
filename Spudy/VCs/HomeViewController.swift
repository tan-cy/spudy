//
//  HomeViewController.swift
//  Spudy
//
//  Created by Cindy Tan on 10/12/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import MapKit
import CoreLocation

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var allBuildingsTableView: UITableView!
    @IBOutlet weak var popularSpotsCollectionView: UICollectionView!
    @IBOutlet weak var yourFriendsAreHereCollectionView: UICollectionView!
    
    
    let textCellIdentifier = "TextCell"
    let friendsCellIdentifier = "FriendsCell"
    let studySpotSegueIdentifier = "studySpotSegueIdentifier"
    let studySpotSegueIdentifier2 = "studySpotSegueIdentifier2"
    let studySpotSegueIdentifier3 = "studySpotSegueIdentifier3"
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        popularSpotsCollectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: "MyCollectionViewCell")
        
        yourFriendsAreHereCollectionView.register(YourFriendsAreHereCollectionViewCell.nib(), forCellWithReuseIdentifier: "YourFriendsAreHereCollectionViewCell")
        
        popularSpotsCollectionView.delegate = self
        popularSpotsCollectionView.dataSource = self
        
        yourFriendsAreHereCollectionView.delegate = self
        yourFriendsAreHereCollectionView.dataSource = self
        
        allBuildingsTableView.delegate = self
        allBuildingsTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.allBuildingsTableView.reloadData()
        self.yourFriendsAreHereCollectionView.reloadData()
        self.popularSpotsCollectionView.reloadData()
    }
    
    
    
    // Took the functions from class demo code library
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = allBuildingsTableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = buildings[row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.scrollToTop()
    }
    
    private func scrollToTop() {
        // 1
        let topRow = IndexPath(row: 0,
                               section: 0)
                               
        // 2
        allBuildingsTableView.scrollToRow(at: topRow,
                                   at: .top,
                                   animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == studySpotSegueIdentifier,
           let destination = segue.destination as? StudySpotViewController,
           let buildingIndex = allBuildingsTableView.indexPathForSelectedRow?.row {
            print("First segue used")
//            destination.building = buildings[buildingIndex].name
            destination.index = buildingIndex
        }
        if segue.identifier == studySpotSegueIdentifier2,
                  let destination2 = segue.destination as? StudySpotViewController, let index2 = sender as? Int {
            destination2.index = index2
        }
        if segue.identifier == studySpotSegueIdentifier3,
                  let destination3 = segue.destination as? StudySpotViewController, let index3 = sender as? Int {
            destination3.index = index3
        }
    }

}

// helps pick up interactions with the cell
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        collectionView.deselectItem(at: indexPath, animated: true)
        
        let selectedItem = indexPath.row
        
        if(collectionView == popularSpotsCollectionView) {
            self.performSegue(withIdentifier: studySpotSegueIdentifier3, sender: selectedItem)
        } else if (collectionView ==  yourFriendsAreHereCollectionView) {
            self.performSegue(withIdentifier: studySpotSegueIdentifier2, sender: selectedItem)
        }
        
    }
    
}

// helps with displaying info
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == popularSpotsCollectionView) {
            return buildings.count
        } else if (collectionView == yourFriendsAreHereCollectionView) {
            return buildings.count
        }
        
        return buildings.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == popularSpotsCollectionView) {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
            
            cell.configure(image: buildings[indexPath.row].image, name: buildings[indexPath.row].name)
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YourFriendsAreHereCollectionViewCell", for: indexPath) as! YourFriendsAreHereCollectionViewCell
            
            cell.configure(image: buildings[indexPath.row].image, name: buildings[indexPath.row].name)
            
            return cell
            
        }
    }
    
}

class building {
    
    var name:String
    var xcoord:Float
    var ycoord:Float
    var image: UIImage
    var studyspots: [String]
    var rating: Float
    
    init(n:String, x:Float, y:Float, i:UIImage, ss:[String], r:Float) {
        name = n
        xcoord = x
        ycoord = y
        image = i
        studyspots = ss
        rating = r
    }
    
}

// lets us specify what is the margin and pattern between each cell
//extension HomeViewController: UICollectionViewDelegateFlowLayout {
//
//}
