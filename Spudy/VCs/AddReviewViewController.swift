//
//  AddReviewViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 11/30/21.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import CoreData

class AddReviewViewController: UIViewController {

    @IBOutlet weak var reviewText: UITextField!
    @IBOutlet weak var ratingText: UITextField!
    var buildingName:String = ""
    var spotName:String = ""
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var buildingText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildingText.text = buildingName
        titleText.text = "Leave a Review for " + spotName
        
        // Do any additional setup after loading the view.
        reviewText.borderStyle = UITextField.BorderStyle.roundedRect
        reviewText.placeholder = "Leave a Review"
        reviewText.borderStyle = UITextField.BorderStyle.roundedRect
        reviewText.contentVerticalAlignment = .top
        
        buildingText.sizeToFit()
    }
    
    
    @IBAction func submitButton(_ sender: Any) {
        // show a notification if either fields are
        // empty that their changes won't save
        // unless hit cancel?
        print(Int(ratingText.text!))
        if reviewText.text == "" || ratingText.text == "" {
            let controller = UIAlertController(
                title: "Fields Not Filled Out",
                message: "All the fields are not filled out.",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "Ok",
                                    style: .default,
                                    handler: nil))
            present(controller, animated: true, completion: nil)
        }
        else if(Float(ratingText.text!) == nil || Float(ratingText.text!) ?? 6.0 > 5.0){
            let controller = UIAlertController(
                title: "Invalid Rating",
                message: "The rating provided is invalid.",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "Ok",
                                    style: .default,
                                    handler: nil))
            present(controller, animated: true, completion: nil)
            
        }
        
        // else save the changes to the reviews of this page
        else{
            var ref:DatabaseReference!
            ref = Database.database().reference(withPath: "buildings/\(buildingName)/studyspots/\(spotName)/\(CURRENT_USERNAME)")
            ref.child("rating").setValue(ratingText.text)
            ref.child("review").setValue(reviewText.text)
            
            let controller = UIAlertController(
                title: "Success",
                message: "Review is submitted!",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "Ok",
                                    style: .default,
                                    handler: nil))
            present(controller, animated: true, completion: nil)
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
