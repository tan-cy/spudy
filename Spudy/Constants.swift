//
//  Constants.swift
//  Spudy
//
//  Created by Cindy Tan on 10/18/21.
//

import Foundation

struct Constants {
    
    struct Segues {
        static let loginSegueIdentifier = "LoginSegueIdentifier"
        static let logoutSegueIdentifier = "LogoutSegueIdentifier"
        static let signupSegueIdentifier = "SignUpSegueIdentifier"

    }
    
    struct Keys {
        
    }
    
    struct Colors {
        
    }
    
    struct Placeholders {
        static let confirmPassword = "Confirm password"
        static let email = "Email"
        static let name = "Name"
        static let password = "Password"
        static let username = "Username"
    }
    
    struct Messages {
        static let badEmail = "Email has bad format"
        static let empty = ""
        static let failedLogin = "Unsuccessful Login"
        static let failedSignOut = "Unsuccessful Sign Out"
        static let failedSignUp = "Unsuccessful Sign Up"
        static let matchPasswords = "Passwords must match"
        static let missingLogin = "Please enter your email and password"
        static let ok = "OK"
        static let shortName = "Name must be longer than 2 letters"
        static let shortPassword = "Password must be longer than 8 characters"
        static let shortUsername = "Username must be 4 or more characters "
    }
    
    struct RegEx {
        static let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        static let regexFormat = "SELF MATCHES %@"
        static let usernameRegEx = "[A-Z0-9a-z.-_]+"
    }
    
}
