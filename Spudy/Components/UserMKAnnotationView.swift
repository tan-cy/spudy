//
//  UserMKAnnotationView.swift
//  Spudy
//
//  Created by Cindy Tan on 11/10/21.
//

import UIKit
import MapKit

class UserMKAnnotationView: MKAnnotationView {
    let title: String?
    let subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var image: UIImage?
    var pinTintColor: UIColor!

    init(name: String, username: String, coord: CLLocationCoordinate2D, photoURLString: String?, pinColor: UIColor) {
        title = name
        subtitle = username
        coordinate = coord
        
        if photoURLString != nil {
            if let photoURL = URL(string: photoURLString!) {
                if let data = try? Data(contentsOf: photoURL) {
                    self.image = UIImage(data: data)
                }
            }
        }
        
        pinTintColor = pinColor
    }
}
