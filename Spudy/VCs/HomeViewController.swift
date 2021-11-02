//
//  HomeViewController.swift
//  Spudy
//
//  Created by Cindy Tan on 10/12/21.
//

import UIKit
import Firebase
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var allBuildingsTableView: UITableView!
    @IBOutlet weak var popularSpotsCollectionView: UICollectionView!
    @IBOutlet weak var yourFriendsAreHereCollectionView: UICollectionView!
    
    let textCellIdentifier = "TextCell"
    let friendsCellIdentifier = "FriendsCell"
    let studySpotSegueIdentifier = "studySpotSegueIdentifier"
    var buildings:[building] = []
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        getData()
        
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
    
    func getData () {
        
        ref = Database.database().reference(withPath: "buildings")
        ref.observe(.value, with: { snapshot in
            
            var newList:[building] = []
            
            for child in (snapshot.children) {
                
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String:Any]
                
                let name = dict["name"] as? String ?? "Unknown"
                let coords:[Float] = dict["coordinates"] as? Array ?? [0.00, 0.00]
                var image:UIImage = UIImage(systemName: "questionmark")!
                let photoURLString = dict ["image"] as? String ?? nil
                
                if photoURLString != nil {
                    if let photoURL = URL(string: photoURLString!) {
                        if let data = try? Data(contentsOf: photoURL) {
                            image = UIImage(data: data) ?? UIImage(systemName: "questionmark")!
                        }
                    }
                }
                
                
                let newBuilding = building(n: name, x: coords[0], y: coords[1], i: image)
                newList.append(newBuilding)
                
                print("(DEBUG) Retrieved building: \(name)")
                
            }
            
            self.buildings = newList
            
            print("(DEBUG) Buildings retrieved!")
        
        })
        
        self.allBuildingsTableView.reloadData()
        self.yourFriendsAreHereCollectionView.reloadData()
        self.popularSpotsCollectionView.reloadData()
        print("(DEBUG) Tables reloaded!")
        
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
           let buildingIndex = allBuildingsTableView.indexPathForSelectedRow?.row{
            destination.building = buildings[buildingIndex].name
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
    
    init(n:String, x:Float, y:Float, i:UIImage) {
        name = n
        xcoord = x
        ycoord = y
        image = i
    }
    
}

// lets us specify what is the margin and pattern between each cell
//extension HomeViewController: UICollectionViewDelegateFlowLayout {
//
//}
