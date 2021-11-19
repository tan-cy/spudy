//
//  LoginViewController.swift
//  Spudy
//
//  Created by Lilly on 10/12/21.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        emailTextField.placeholder = Constants.Placeholders.email
        passwordTextField.placeholder = Constants.Placeholders.password
        
        passwordTextField.isSecureTextEntry = true
        
        ref = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)

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
                  // fetch current users
                  for username in values!.allKeys {
                      let userInfo = values?.value(forKey: username as! String) as? NSDictionary
                      if (userInfo!.value(forKey: Constants.DatabaseKeys.email) as? String == user?.email) {

                          // store into core data
                          let newSignedIn = NSEntityDescription.insertNewObject(forEntityName: Constants.CoreKeys.userEntity, into: Constants.context)
                          newSignedIn.setValue(username, forKey: Constants.CoreKeys.username)
                          
                          CURRENT_USERNAME = username as! String
                          print("current user is " + CURRENT_USERNAME)
                          
                          // fetch current users
                          let fetchedResults = self.retrieveCurrentUser()

                          // if no user exists
                          if (fetchedResults.isEmpty) {
                              print("no user exists")
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
                          break;
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
    
    @IBAction func touchGoogleLogin(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

            if error != nil {
                let errorAlert = UIAlertController(title: "Unable to Login", message: "We were not able to login using your Google Account.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(errorAlert, animated: true, completion: nil)
                return
            }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            googleSignIn(credential: credential)
        
        }
    }
    
    func googleSignIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if error != nil {
                let errorAlert = UIAlertController(title: "Unable to Login", message: "We were not able to login using your Google Account.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            } else {
                // check if this is a new user logging in w google
                guard let newUserStatus = authResult?.additionalUserInfo?.isNewUser else { return }
                    
                if newUserStatus {
                    // time to make their username and store it in firebase!
                    let profileData = authResult?.additionalUserInfo?.profile as! [String: Any]
                    
                    let name = profileData["name"] as? String ?? "Unknown"
                    let email = profileData["email"] as! String
                    
                    // create username using the email
                    let endIndex = email.firstIndex(of: "@")
                    let username = email.prefix(email.distance(from: email.startIndex, to: endIndex!))
                    
                    var reformatUsername = ""
                    username.forEach { currChar in
                        if currChar == "." {
                            reformatUsername.append("_")
                        } else if !"#$[]".contains(currChar) {
                            reformatUsername.append(currChar)
                        }
                    }
                    
                    self.initializeUserData(username: String(reformatUsername), email: email, name: name)
                }
            }
        }
    }
    
    func initializeUserData(username: String, email: String, name: String) {
        let newItemRef = self.ref.child(username)
        newItemRef.child(Constants.DatabaseKeys.email).setValue(email)
        newItemRef.child(Constants.DatabaseKeys.name).setValue(name)
        
        // profile data
        newItemRef.child(Constants.DatabaseKeys.classes).setValue([])
        newItemRef.child(Constants.DatabaseKeys.contactInfo).setValue("")
        newItemRef.child(Constants.DatabaseKeys.gradYear).setValue("")
        newItemRef.child(Constants.DatabaseKeys.major).setValue("")
        newItemRef.child(Constants.DatabaseKeys.photo).setValue("")
        
        // settings data
        let settingsRef = newItemRef.child(Constants.DatabaseKeys.settings)
        let settingsData: [String : Any] = [
            Constants.DatabaseKeys.selfStudy: false,
            Constants.DatabaseKeys.notificationSetting: Constants.LocationSettings.everyone.rawValue,
            Constants.DatabaseKeys.locationSetting: Constants.LocationSettings.everyone.rawValue
        ]
        settingsRef.setValue(settingsData)
    }
    
}
