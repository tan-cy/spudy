//
//  SearchViewController.swift
//  Spudy
//
//  Created by Lilly on 12/1/21.
//

import UIKit
import simd

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var buildingsSearchBar: UISearchBar!
    @IBOutlet weak var buildingsTableView: UITableView!
    
    let tableViewCellIdentifier = "searchTableViewCell"
    let segueIdentifier = "searchToStudySpotSegueIdentifier"
    
    var filteredData: [building]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildingsTableView.delegate = self
        buildingsTableView.dataSource = self
        buildingsSearchBar.delegate = self
        filteredData = buildings

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = buildingsTableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = filteredData[indexPath.row].name
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? buildings : buildings.filter { (item) in
            
            return item.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        buildingsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier,
           let destination = segue.destination as? StudySpotViewController,
           let filteredIndex = buildingsTableView.indexPathForSelectedRow?.row {
            
            let building = filteredData[filteredIndex]
            let actualIndex = buildings.firstIndex(where: { (currBuilding) in
               return building.name == currBuilding.name
            })
        
            destination.index = actualIndex ?? 0
        }
    
    }

}
