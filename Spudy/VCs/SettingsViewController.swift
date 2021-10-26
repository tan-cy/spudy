//
//  SettingsViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 10/12/21.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var selfStudyModeSwitch: UISwitch!
    var user: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: CHANGE WITH BACKEND
        selfStudyModeSwitch.isOn = user
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeSelfStudyMode(_ sender: Any) {
        user = selfStudyModeSwitch.isOn
    }
    
    @IBAction func touchChangeNotifSettings(_ sender: Any) {
        let controller = UIAlertController(title: "Change notification settings", message: nil, preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "Send me all notifications", style: .default, handler: nil))
        controller.addAction(UIAlertAction(title: "Notify me when friends are near", style: .default, handler: nil))
        controller.addAction(UIAlertAction(title: "Don't send me notifications", style: .default, handler: nil))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func touchChangeLocationSettings(_ sender: Any) {
        let controller = UIAlertController(title: "Share my location with:", message: nil, preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "Everyone", style: .default, handler: nil))
        controller.addAction(UIAlertAction(title: "Just friends", style: .default, handler: nil))
        controller.addAction(UIAlertAction(title: "Don't share my location", style: .default, handler: nil))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func touchSignOut(_ sender: Any) {
        let controller = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out of your account?", preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: {(action) in self.signUserOut()}))

        present(controller, animated: true, completion: nil)
    }
    
    func signUserOut() {
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
    
    @IBAction func touchDeleteAccount(_ sender: Any) {
        let controller = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in self.deleteUser()}))
        
        present(controller, animated: true, completion: nil)
    }
    
    func deleteUser() {
        print("will delete user...")
    }
}
