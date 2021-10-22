//
//  SettingsViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 10/12/21.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func touchSignOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: Constants.Segues.logoutSegueIdentifier, sender: nil)
        }
        catch let error as NSError
        {
            let alert = UIAlertController(
                title: Constants.Messages.failedSignOut,
              message: error.localizedDescription,
              preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.Messages.ok, style:.default))
            self.present(alert, animated: true, completion: nil)
        }

    }
    
}
