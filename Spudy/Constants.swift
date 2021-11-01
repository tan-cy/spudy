//
//  Constants.swift
//  Spudy
//
//  Created by Cindy Tan on 10/18/21.
//

import Foundation
import UIKit

struct Constants {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    struct Segues {
        static let filterSegueIdentifier = "FilterSegueIdentifier"
        static let loginSegueIdentifier = "LoginSegueIdentifier"
        static let logoutSegueIdentifier = "LogoutSegueIdentifier"
        static let signupSegueIdentifier = "SignUpSegueIdentifier"

    }
    
    struct DatabaseKeys {
        static let email = "email"
        static let name = "name"
        static let classes = "classes"
        static let classPath = "people_in_courses"
        static let contactInfo = "contactInfo"
        static let friends = "friends"
        static let gradYear = "gradYear"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let major = "major"
        static let photo = "photo"
        static let profilePath = "profile"
    }
    
    struct CoreKeys {
        static let userEntity = "Users"
        static let username = "username"
    }
    
    struct Colors {
        
    }
    
    struct Filters {
        static let everyone = "everyone"
        static let friends = "friends"
        static let classmates = "classmates"
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
        static let shortUsername = "Username must be 4 or more characters"
        static let userTaken = "Username already in use"
    }
    
    struct RegEx {
        static let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        static let regexFormat = "SELF MATCHES %@"
        static let usernameRegEx = "[A-Z0-9a-z.-_]+"
    }
    
}
