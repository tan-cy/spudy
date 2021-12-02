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
        
        if photoURLString != nil, let url = URL(string: photoURLString!), let data = try? Data(contentsOf: url) {
            image = UIImage(data: data)?.circleMasked
        } else {
            image = UIImage(systemName: "person.circle.fill")?.withTintColor(UIColor.systemBlue, renderingMode: .alwaysTemplate)
        }
        image = image?.resizeImage(targetSize: CGSize(width: 25, height: 25))
    }
}
extension UIImage {
    var isPortrait:  Bool    { size.height > size.width }
    var isLandscape: Bool    { size.width > size.height }
    var breadth:     CGFloat { min(size.width, size.height) }
    var breadthSize: CGSize  { .init(width: breadth, height: breadth) }
    var breadthRect: CGRect  { .init(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        guard let cgImage = cgImage?
            .cropping(to: .init(origin: .init(x: isLandscape ? ((size.width-size.height)/2).rounded(.down) : 0,
                                              y: isPortrait  ? ((size.height-size.width)/2).rounded(.down) : 0),
                                size: breadthSize)) else { return nil }
        let format = imageRendererFormat
        format.opaque = false
        return UIGraphicsImageRenderer(size: breadthSize, format: format).image { _ in
            UIBezierPath(ovalIn: breadthRect).addClip()
            UIImage(cgImage: cgImage, scale: format.scale, orientation: imageOrientation)
            .draw(in: .init(origin: .zero, size: breadthSize))
        }
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
