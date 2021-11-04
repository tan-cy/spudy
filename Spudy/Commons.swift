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
var buildings:[building] = []
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
            let dict = snap.value as! [String:Any]
            
            let name = dict["name"] as? String ?? "Unknown"
            let coords:[Float] = dict["coordinates"] as? Array ?? [0.00, 0.00]
            var image:UIImage = UIImage(systemName: "questionmark")!
            let photoURLString = dict ["image"] as? String ?? nil
            
            if photoURLString != nil {
                if let photoURL = URL(string: photoURLString!) {
                    if let data = try? Data(contentsOf: photoURL) {
                        image = UIImage(data: data) ?? UIImage(systemName: "questionmark")!
                    }
                }
            }
            
            
            let newBuilding = building(n: name, x: coords[0], y: coords[1], i: image)
            newList.append(newBuilding)
            
            print("(DEBUG) Retrieved building: \(name)")
            
        }
        
        buildings = newList
        print("(DEBUG) Buildings retrieved!")
        completion?()
    
    })

}
