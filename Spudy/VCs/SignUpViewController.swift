//
//  SignUpViewController.swift
//  Spudy
//
//  Created by Lilly on 10/12/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    var ref: DatabaseReference!
    var users: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameTextField.placeholder = Constants.Placeholders.username
        emailTextField.placeholder = Constants.Placeholders.email
        nameTextField.placeholder = Constants.Placeholders.name
        passwordTextField.placeholder = Constants.Placeholders.password
        confirmPasswordTextField.placeholder = Constants.Placeholders.confirmPassword
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true

        ref = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)

        Auth.auth().addStateDidChangeListener() {
          auth, user in
          
          if user != nil {
              self.performSegue(withIdentifier: Constants.Segues.signupSegueIdentifier, sender: nil)
              self.usernameTextField.text = nil
              self.emailTextField.text = nil
              self.nameTextField.text = nil
              self.passwordTextField.text = nil
              self.confirmPasswordTextField.text = nil
              
          }
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
    @IBAction func touchSignUp(_ sender: Any) {
        let alert = UIAlertController(
          title: Constants.Messages.failedSignUp,
          message: Constants.Messages.empty,
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.Messages.ok, style:.default))
        let usernamePred = NSPredicate(format:Constants.RegEx.regexFormat, Constants.RegEx.usernameRegEx)
        guard let username = usernameTextField.text,
              username.count > 3,
              usernamePred.evaluate(with: username)
        else {
            alert.message = Constants.Messages.shortUsername
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let emailPred = NSPredicate(format: Constants.RegEx.regexFormat, Constants.RegEx.emailRegEx)
        guard let email = emailTextField.text,
              email.count > 0,
              emailPred.evaluate(with: email)
        else {
            alert.message = Constants.Messages.badEmail
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let name = nameTextField.text,
              name.count > 2
        else {
            alert.message = Constants.Messages.shortName
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let password = passwordTextField.text,
              password.count >= 8
        else {
            
            alert.message = Constants.Messages.shortPassword
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let confirm = confirmPasswordTextField.text,
              confirm == password
        else {
            alert.message = Constants.Messages.matchPasswords
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        ref.observe(.value) { snapshot in
            let values = snapshot.value as? NSDictionary
            let userExists = values?[username] != nil
            
            if (userExists) {
                alert.message = Constants.Messages.userTaken
                self.present(alert, animated: true, completion: nil)
                return
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { user, error in
                    if error == nil {
                        let newItemRef = self.ref.child(username)
                        newItemRef.child(Constants.DatabaseKeys.email).setValue(email)
                        newItemRef.child(Constants.DatabaseKeys.name).setValue(name)
                        newItemRef.child(Constants.DatabaseKeys.classes).setValue([])
                        newItemRef.child(Constants.DatabaseKeys.contactInfo).setValue("")
                        newItemRef.child(Constants.DatabaseKeys.gradYear).setValue("")
                        newItemRef.child(Constants.DatabaseKeys.major).setValue("")
                        newItemRef.child(Constants.DatabaseKeys.photo).setValue("")
                        
                        Auth.auth().signIn(withEmail: self.emailTextField.text!,
                                           password: self.passwordTextField.text!)
                    } else {
                        alert.message = error?.localizedDescription
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
