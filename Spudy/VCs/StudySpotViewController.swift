//
//  StudySpotViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 10/12/21.
//

import UIKit
import Firebase
import FirebaseDatabase

class StudySpotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var studySpotsTableView: UITableView!
    
    var building = ""
    var ref: DatabaseReference!
    var studySpots: [String] = []
    let textCellIdentifier = "TextCell"
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studySpots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = studySpotsTableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = studySpots[row]
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        studySpotsTableView.delegate = self
        studySpotsTableView.dataSource = self

        // Do any additional setup after loading the view.
        ref = Database.database().reference(withPath: "\(building)")
        print(building)
        
        ref.observe(.value, with: {snapshot in
            let value = snapshot.value as? NSDictionary
            self.studySpots = value?.value(forKey: "studyspots") as? [String] ?? []
            self.studySpotsTableView.reloadData()
        }
        )
        
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
