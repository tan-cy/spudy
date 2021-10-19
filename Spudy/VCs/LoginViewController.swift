//
//  LoginViewController.swift
//  Spudy
//
//  Created by Lilly on 10/12/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.placeholder = Constants.Placeholders.email
        passwordTextField.placeholder = Constants.Placeholders.password
        
        passwordTextField.isSecureTextEntry = true

        Auth.auth().addStateDidChangeListener() {
          auth, user in
          
          if user != nil {
              self.performSegue(withIdentifier: Constants.Segues.loginSegueIdentifier, sender: nil)
            self.emailTextField.text = nil
            self.passwordTextField.text = nil
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
