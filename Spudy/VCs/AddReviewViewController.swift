//
//  AddReviewViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 11/30/21.
//

import UIKit

class AddReviewViewController: UIViewController {

    @IBOutlet weak var reviewText: UITextField!
    @IBOutlet weak var ratingText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reviewText.borderStyle = UITextField.BorderStyle.roundedRect
    }
    
    @IBAction func submitButton(_ sender: Any) {
        // show a notification if either fields are
        // empty that their changes won't save
        // unless hit cancel?
        if reviewText.text == "" || ratingText.text == "" {
            let controller = UIAlertController(
                title: "Fields Not Filled Out",
                message: "All the fields are not filled out. If you decide to continue, then your changes will not be saved.",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                                    title: "Ok",
                                    style: .default,
                                    handler: nil))
            present(controller, animated: true, completion: nil)
        }
        
        // else save the changes to the reviews of this page
        
        let otherVC = delegate as! AddReview
        otherVC.addNewReview(review: reviewText.text, rating: ratingText.text)
        
        
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
