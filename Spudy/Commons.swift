//
//  CommonDatabaseAccess.swift
//  Spudy
//
//  Created by Cindy Tan on 11/2/21.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import CoreData

var CURRENT_USERNAME = ""
var selfStudyMode:Bool!
var buildings:[building] = []
var friendList:[String] = []
var bookmarks:[String] = []

internal func getUsername() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
    // to store results of request
    var fetchedResults:[NSManagedObject]? = nil
    
    do {
        // get username of current person logged in
        try fetchedResults = context.fetch(request) as? [NSManagedObject]
        CURRENT_USERNAME = (fetchedResults != []) ? fetchedResults?[0].value(forKey: "username") as! String : ""
        print("current user is " + CURRENT_USERNAME)
    } catch {
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
    }
}

internal func getData (completion:(() -> ())?) {
    
    var newList:[building] = []
    
    var ref: DatabaseReference!
    ref = Database.database().reference(withPath: "buildings")
    ref.observe(.value, with: { snapshot in
        
        for child in (snapshot.children) {
            
            let snap = child as! DataSnapshot
            let dict = snap.value as! NSDictionary
            let name = dict["name"] as? String ?? "Unknown"
            
            guard let coorddict = dict["coordinates"] as? NSArray else {
                print("(DEBUG) No coordinates found")
                return
            }
            let xcoord = (coorddict.object(at: 0) as? NSNumber)?.floatValue
            let ycoord = (coorddict.object(at: 1) as? NSNumber)?.floatValue
            
            let rating:Double = dict["rating"] as? Double ?? 0.00
            var image:UIImage = UIImage(systemName: "questionmark")!
            let photoURLString = dict ["image"] as? String ?? nil
            let studyDict = dict["studyspots"] as? NSDictionary ?? [:]
            
            if photoURLString != nil {
                if let photoURL = URL(string: photoURLString!) {
                    if let data = try? Data(contentsOf: photoURL) {
                        image = UIImage(data: data) ?? UIImage(systemName: "questionmark")!
                    }
                }
            }
            
            
            let newBuilding = building(n: name, x: xcoord!, y: ycoord!, i: image, ss: studyDict, r:rating)

            newList.append(newBuilding)
            
            print("(DEBUG) Retrieved building: \(name) - rating is \(rating)")
            
        }
        
        buildings = newList
        print("(DEBUG) Buildings retrieved!")
        
        completion?()
    
    })

    getUserData()
}

func getUserData() {
    let profileRef = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
    profileRef.observe(.value) { snapshot in
        let profiles = snapshot.value as? NSDictionary
        let user = profiles?[CURRENT_USERNAME] as? NSDictionary
        
        selfStudyMode = ((user?[Constants.DatabaseKeys.settings] as? NSDictionary)?[Constants.DatabaseKeys.selfStudy] as? Bool ?? false)
        friendList = user?[Constants.DatabaseKeys.friends] as? [String] ?? []
        bookmarks = user?[Constants.DatabaseKeys.bookmarks] as? [String] ?? []
    }
}
