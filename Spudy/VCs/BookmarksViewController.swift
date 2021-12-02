//
//  BookmarksViewController.swift
//  Spudy
//
//  Created by Cindy Tan on 12/1/21.
//

import UIKit

class BookmarksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noBookmarksMessage: UILabel!
    @IBOutlet weak var bookmarkTableView: UITableView!
    
    var bookmarkOwnerName:String = "Unknown"
    var userBookmarks: [String]!
    let bookmarkCellIdentifier = "BookmarkTextCell"
    let studySpotSegueIdentifier = "StudySpotSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bookmarkTableView.delegate = self
        bookmarkTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleLabel.text = "\(bookmarkOwnerName)'s Bookmarks"
        noBookmarksMessage.isHidden = userBookmarks.count != 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == studySpotSegueIdentifier),
           let destination = segue.destination as? StudySpotViewController,
           let bookmarkIdx = bookmarkTableView.indexPathForSelectedRow?.row {
            let buildingIndex = buildings.firstIndex(where: {$0.name == userBookmarks[bookmarkIdx]})!
            destination.index = buildingIndex
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userBookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = bookmarkTableView.dequeueReusableCell(withIdentifier: bookmarkCellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = userBookmarks[row]

        return cell
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
