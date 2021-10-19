//
//  UserData.swift
//  Spudy
//
//  Created by Cindy Tan on 10/19/21.
//

import Foundation

class User {
    var username:String
    var name:String
    var email:String
    init (username: String, name: String, email: String) {
        self.username = username
        self.name = name
        self.email = email
    }
}
