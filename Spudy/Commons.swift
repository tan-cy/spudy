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
internal func getUsername() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
    // to store results of request
    var fetchedResults:[NSManagedObject]? = nil
    
    do {
        // get username of current person logged in
        try fetchedResults = context.fetch(request) as? [NSManagedObject]
        CURRENT_USERNAME = fetchedResults?[0].value(forKey: "username") as! String
    } catch {
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
    }
}
