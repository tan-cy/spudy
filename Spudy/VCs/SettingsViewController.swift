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
    var username = ""
    var selfStudy: Bool = false
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUsername()
        
        ref = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
        ref.observe(.value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: self.username) as? NSDictionary
            
            let settings = user?[Constants.DatabaseKeys.settings] as? NSDictionary
            
            self.selfStudyModeSwitch.isOn = settings?[Constants.DatabaseKeys.selfStudy] as? Bool ?? false
        })
        
    }
    
    func getUsername() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreKeys.userEntity)
        // to store results of request
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            // get username of current person logged in
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
            username = fetchedResults?[0].value(forKey: Constants.CoreKeys.username) as! String
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    @IBAction func changeSelfStudyMode(_ sender: Any) {
        print(selfStudyModeSwitch.isOn)
        let newItemRef = self.ref.child(username).child(Constants.DatabaseKeys.settings)
        
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
        let newItemRef = self.ref.child(username).child(Constants.DatabaseKeys.settings)
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
        let newItemRef = self.ref.child(username).child(Constants.DatabaseKeys.settings)
        newItemRef.child(Constants.DatabaseKeys.locationSetting).setValue(setting.rawValue)
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
                self.ref.child("\(self.username)").removeValue()
            }
        }
    }
    

}
