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
    var imageView: UIImageView!
    var image: UIImage!
    var color: UIColor
    
    init(name: String, username: String, coord: CLLocationCoordinate2D, photoURLString: String?, pinColor: UIColor) {
        title = name
        subtitle = username
        coordinate = coord
        
        if photoURLString != nil, let url = URL(string: photoURLString!), let data = try? Data(contentsOf: url) {
            imageView = UIImageView(image: UIImage(data: data))
        } else {
            imageView = UIImageView(image: UIImage(systemName: "person.circle.fill"))
            imageView.backgroundColor = UIColor.white
            imageView.tintColor = UIColor.systemBlue
        }
    
        imageView.frame = CGRect(x:0, y:0, width:30, height:30)
        imageView.layer.cornerRadius = imageView.layer.frame.size.width / 2
        imageView.layer.masksToBounds = true

        color = pinColor
    }
}
