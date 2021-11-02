//
//  MyCollectionViewCell.swift
//  Spudy
//
//  Created by Janssen Bozon on 10/18/21.
//

import UIKit

// custom implementation of ui colllection view cell
// xib file is the template that the storyboard will use
class MyCollectionViewCell: UICollectionViewCell {
    
    var cornerRadius: CGFloat = 5.0
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var buildingNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.black.cgColor
        
    }
    
    public func configure(image: UIImage, name: String) {
        imageView.image =  image
        buildingNameLabel.text = name
    }
    
    // tells collection view hey we have a cell use it
    static func nib() ->UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }

}
