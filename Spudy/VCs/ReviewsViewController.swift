//
//  ReviewsViewController.swift
//  Spudy
//
//  Created by Cindy Tan on 10/12/21.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import CoreData



class ReviewsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    

    @IBOutlet weak var reviewCollectionView: UICollectionView!
    
    var textCellIdentifier = "ReviewCellIdentifier"
    var addReviewSegueIndentifier = "addReviewSegueIndentifier"
    
    var review:NSDictionary = [:]
    var reviewList:[String] = []
    var userList:[String] = []
    var ratingList:[String] = []
    var buildingName:String = ""
    var spotName:String = ""

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviewList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: textCellIdentifier, for: indexPath) as! ReviewCollectionViewCell
        
        cell.usernameLabel.text = userList[indexPath.row]
        cell.reviewLabel.text = reviewList[indexPath.row]
        cell.ratingLabel.text = ratingList[indexPath.row]
        
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 15
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.masksToBounds = false
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.7
        cell.layer.shadowOffset = CGSize(width:5, height:5)
        cell.layer.shadowRadius = 4
        
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        let containerWidth = reviewCollectionView.bounds.width
        layout.itemSize = CGSize(width:containerWidth, height:100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        reviewCollectionView.collectionViewLayout = layout
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        reviewCollectionView.delegate = self
        reviewCollectionView.dataSource = self
        // get review
        getReview()
        setLists()
        self.reviewCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getReview()
        setLists()
        
        self.reviewCollectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addReviewSegueIndentifier,
           let destination = segue.destination as? AddReviewViewController{
            destination.buildingName = self.buildingName
            destination.spotName = self.spotName
        }
    }
    
    func getReview(){
        var ref: DatabaseReference!
        ref = Database.database().reference(withPath: "buildings/\(buildingName)/studyspots/\(spotName)")
        ref.observe(.value) { snapshot in
            self.review = snapshot.value as? NSDictionary ?? [:]
        }
    }
    
    func setLists(){
        reviewList = []
        userList = []
        ratingList = []
         
        userList = review.allKeys as! [String]
        for key in userList{
            let user = review.value(forKey: key) as! NSDictionary
            reviewList.append(user.value(forKey: "review") as! String)
            ratingList.append(user.value(forKey: "rating") as! String)
        }
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
