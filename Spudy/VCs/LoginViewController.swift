//
//  LoginViewController.swift
//  Spudy
//
//  Created by Lilly on 10/12/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.placeholder = Constants.Placeholders.email
        passwordTextField.placeholder = Constants.Placeholders.password
        
        passwordTextField.isSecureTextEntry = true

        clearCoreData()
        Auth.auth().addStateDidChangeListener() { auth, user in
          if user != nil {
              self.performSegue(withIdentifier: Constants.Segues.loginSegueIdentifier, sender: nil)
              self.emailTextField.text = nil
              self.passwordTextField.text = nil

              // get username from server
              let ref = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
              ref.observe(.value) { snapshot in
                  let values = snapshot.value as? NSDictionary
                  for username in values!.allKeys {
                      let userInfo = values?.value(forKey: username as! String) as? NSDictionary
                      if (userInfo!.value(forKey: Constants.DatabaseKeys.email) as? String == user?.email) {

                          // fetch current users
                          let fetchedResults = self.retrieveCurrentUser()

                          // if no user exists
                          if (fetchedResults.isEmpty) {
                              let newSignedIn = NSEntityDescription.insertNewObject(forEntityName: Constants.CoreKeys.userEntity, into: Constants.context)
                              newSignedIn.setValue(username, forKey: Constants.CoreKeys.username)
                          } else {
                              // store into core data
                              fetchedResults[0].setValue(username, forKey: Constants.CoreKeys.username)
                          }

                          do {
                              try Constants.context.save()
                          } catch {
                              print("Error saving username into CoreData")
                          }
                      }
                  }
              }
          }
        }
    }
    
    func clearCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreKeys.userEntity)
        var fetchedResults:[NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                    print("\(result.value(forKey: "username")!) has been deleted")
                }
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func retrieveCurrentUser()->[NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreKeys.userEntity)
        var fetchedResults:[NSManagedObject]? = nil

        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return (fetchedResults ?? [])
    }
    
    @IBAction func touchLogin(_ sender: Any) {
        let alert = UIAlertController(
            title: Constants.Messages.failedLogin,
            message: Constants.Messages.empty,
          preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Constants.Messages.ok, style:.default))
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email.count > 0,
              password.count > 0
        else {
            alert.message = Constants.Messages.missingLogin
            self.present(alert, animated: true, completion: nil)
            return
        }
        Auth.auth().signIn(withEmail: email, password: password){
          user, error in
          if let error = error, user == nil {
              alert.message = error.localizedDescription
              self.present(alert, animated: true, completion: nil)
          }
        }
    }
    
}
