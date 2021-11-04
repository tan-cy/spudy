//
//  YourFriendsAreHereCollectionViewCell.swift
//  Spudy
//
//  Created by Janssen Bozon on 10/19/21.
//

import UIKit

class YourFriendsAreHereCollectionViewCell: UICollectionViewCell {
    
    var cornerRadius: CGFloat = 5.0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buildingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.black.cgColor
    }
    
    public func configure(image: UIImage, name: String) {
        imageView.image = image
        buildingLabel.text = name
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "YourFriendsAreHereCollectionViewCell", bundle: nil)
    }

}
