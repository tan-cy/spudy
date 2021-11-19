//
//  SettingsViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 10/12/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreData

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var selfStudyModeSwitch: UISwitch!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
        self.selfStudyModeSwitch.isOn = selfStudyMode
        
    }
    
    @IBAction func changeSelfStudyMode(_ sender: Any) {
        let newItemRef = self.ref.child(CURRENT_USERNAME).child(Constants.DatabaseKeys.settings)
        
        newItemRef.child(Constants.DatabaseKeys.selfStudy).setValue(selfStudyModeSwitch.isOn)
    }
    
    @IBAction func touchChangeNotifSettings(_ sender: Any) {
        let controller = UIAlertController(title: "Change notification settings", message: nil, preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "Send me all notifications", style: .default, handler: { (action) in
            self.submitNotifSettings(setting: Constants.NotificationSettings.all)
        }))
        controller.addAction(UIAlertAction(title: "Notify me when friends are near", style: .default, handler: { (action) in
            self.submitNotifSettings(setting: Constants.NotificationSettings.friends)
        }))
        controller.addAction(UIAlertAction(title: "Don't send me notifications", style: .default, handler: { (action) in
            self.submitNotifSettings(setting: Constants.NotificationSettings.none)
        }))
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(controller, animated: true, completion: nil)
    }
    
    func submitNotifSettings(setting: Constants.NotificationSettings) {
        let newItemRef = self.ref.child(CURRENT_USERNAME).child(Constants.DatabaseKeys.settings)
        newItemRef.child(Constants.DatabaseKeys.notificationSetting).setValue(setting.rawValue)
    }
    
    @IBAction func touchChangeLocationSettings(_ sender: Any) {
        let controller = UIAlertController(title: "Share my location with:", message: nil, preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "Everyone", style: .default, handler: { (action) in
            self.submitLocationSettings(setting: Constants.LocationSettings.everyone)
        }))
        controller.addAction(UIAlertAction(title: "Just friends", style: .default, handler: { (action) in
            self.submitLocationSettings(setting: Constants.LocationSettings.friends)
        }))
        controller.addAction(UIAlertAction(title: "Don't share my location", style: .default, handler: { (action) in
            self.submitLocationSettings(setting: Constants.LocationSettings.none)
        }))
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(controller, animated: true, completion: nil)
    }
    
    func submitLocationSettings(setting: Constants.LocationSettings) {
        let newItemRef = self.ref.child(CURRENT_USERNAME)
        let newItemRefSettings = newItemRef.child(Constants.DatabaseKeys.settings)
        newItemRefSettings.child(Constants.DatabaseKeys.locationSetting).setValue(setting.rawValue)
        // erase user location from database 
        if (setting == Constants.LocationSettings.none) {
            newItemRef.child(Constants.DatabaseKeys.latitude).setValue(Double.greatestFiniteMagnitude)
            newItemRef.child(Constants.DatabaseKeys.longitude).setValue(Double.greatestFiniteMagnitude)
        }
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
        let user = Auth.auth().currentUser

        user?.delete { error in
            if error != nil {
                let controller = UIAlertController(title: "Error", message: "We could not delete your account.", preferredStyle: .alert)

                controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                self.present(controller, animated: true, completion: nil)
            } else {
                // delete user was a success, so sign out user & remove from database
                self.signUserOut()
                self.ref.child("\(CURRENT_USERNAME)").removeValue()
            }
        }
    }
    

}
