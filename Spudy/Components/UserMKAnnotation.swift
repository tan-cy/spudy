//
//  UserMKAnnotation.swift
//  Spudy
//
//  Created by Cindy Tan on 11/1/21.
//

import UIKit
import MapKit

class UserMKAnnotation: NSObject, MKAnnotation {

    let title: String?
    let subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var image: UIImage?
    
    init(name: String, username: String, coord: CLLocationCoordinate2D, photoURLString: String?) {
        title = name
        subtitle = username
        coordinate = coord
        
        if photoURLString != nil {
            if let photoURL = URL(string: photoURLString!) {
                if let data = try? Data(contentsOf: photoURL) {
                    image = UIImage(data: data)
                }
            }
        }
    }
}
