//
//  HomeViewController.swift
//  Spudy
//
//  Created by Cindy Tan on 10/12/21.
//

import UIKit

public let buildings = ["Battle Hall", "Belo Center for New Media", "Biomedical Engineering Building", "Burdine Hall", "College of Business Administration Building", "Peter T. Flawn Academic Center", "Garrison Hall", "Norman Hackerman Building", "Perry–Castañeda Library", "Welch Hall", "Engineering Education and Research Center", "Gates Dell Complex", "Rowling", "William C. Powers Student Activity Center"]

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var allBuildingsTableView: UITableView!
    @IBOutlet weak var popularSpotsCollectionView: UICollectionView!
    @IBOutlet weak var yourFriendsAreHereCollectionView: UICollectionView!
    
    let textCellIdentifier = "TextCell"
    let friendsCellIdentifier = "FriendsCell"
    let studySpotSegueIdentifier = "studySpotSegueIdentifier"
    
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
    
    // Took the functions from class demo code library
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = allBuildingsTableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = buildings[row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
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
           let buildingIndex = allBuildingsTableView.indexPathForSelectedRow?.row{
            destination.building = buildings[buildingIndex]
        }
    }

}

// helps pick up interactions with the cell
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("You tapped me!")
        
    }
    
}

// helps with displaying info
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == popularSpotsCollectionView) {
            return 12
        } else if (collectionView == yourFriendsAreHereCollectionView) {
            return 8
        }
        
        return 4
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == popularSpotsCollectionView) {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
            
            cell.configure(with: UIImage(named: "SAC")!)
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YourFriendsAreHereCollectionViewCell", for: indexPath) as! YourFriendsAreHereCollectionViewCell
            
            cell.configure(image: UIImage(named: "SAC")!)
            
            return cell
            
        }
    }
    
}

// lets us specify what is the margin and pattern between each cell
//extension HomeViewController: UICollectionViewDelegateFlowLayout {
//
//}
