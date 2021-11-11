//
//  FriendsViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 10/12/21.
//

import UIKit
import FirebaseDatabase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var profileRef: DatabaseReference!
    var friendsList: [String: Any] = [:]
    var friendsKeysSorted: [String] = []
    let cellIdentifier = "friendsTableIdentifier"
    let segueIdentifier = "friendsProfileSegueIdentifier"

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
//
//        tableView.register(FriendsTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        profileRef = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
        
        profileRef.observe(.value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: CURRENT_USERNAME) as? NSDictionary
            
            let friends = user?[Constants.DatabaseKeys.friends] as? [String] ?? []
            
            let group = DispatchGroup()

            friends.forEach({ friendID in
                
                group.enter()
                
                self.profileRef.child(friendID).getData() { (_, friendSnap) in
                    var friendUser = friendSnap.value as? NSDictionary
                    friendUser = friendUser?[friendID] as? NSDictionary
                    
                    let name = friendUser?["name"] as? String ?? "Unknown"
                    let photo = friendUser?["photo"] as? String ?? nil
                    
                    self.friendsList[name] =  [
                        "username": friendID,
                        "photo": photo
                    ]
                    
                    group.leave()
                }
            })
            
            group.notify(queue: .main) {
                self.friendsKeysSorted = self.friendsList.keys.sorted(by: <)
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsKeysSorted.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendsTableViewCell

        let name = friendsKeysSorted[indexPath.row]
        cell.setName(name: name)
        
        let userData = friendsList[name] as! NSDictionary
        let username = userData["username"] as! String
        cell.setUsername(username: username)
        
        let photoURL = userData["photo"] as? String ?? nil

        if photoURL != nil, let url = URL(string: photoURL!), let data = try? Data(contentsOf: url) {
            cell.setPhoto(photo: UIImage(data: data)!)
        } else {
            cell.setPhoto(photo: UIImage(systemName: "person.circle.fill")!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier, let destination = segue.destination as? ProfileViewController {
            
            let nameClicked = friendsKeysSorted[tableView.indexPathForSelectedRow!.row]
            let userData = friendsList[nameClicked] as! NSDictionary
            let usernameClicked = userData["username"] as! String
            
            destination.userToGet = usernameClicked
        }
    }
    /*
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.filterSegueIdentifier,
            let destination = segue.destination as? ChipMapFiltersViewController {
            destination.mapFilterDelegate = self
        } else if segue.identifier == Constants.Segues.chipSegueIdentifier,
            let destination = segue.destination as? ProfileViewController,
            let annotation = sender as? UserMKAnnotation {
            destination.userToGet = annotation.subtitle!
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let location = view.annotation?.coordinate
        let region = MKCoordinateRegion.init(center: location!, latitudinalMeters: 200, longitudinalMeters: 200)
        chipMap.setRegion(region, animated: true)
        let annotation = (view.annotation as? UserMKAnnotation)
        if let selectedUsername = annotation?.subtitle,
            selectedUsername != CURRENT_USERNAME {
//            print(selectedUsername)
            performSegue(withIdentifier: Constants.Segues.chipSegueIdentifier, sender: annotation)
        }
    }*/

}
