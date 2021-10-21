//
//  YourFriendsAreHereCollectionViewCell.swift
//  Spudy
//
//  Created by Janssen Bozon on 10/19/21.
//

import UIKit

class YourFriendsAreHereCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(image: UIImage) {
        imageView.image = image
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "YourFriendsAreHereCollectionViewCell", bundle: nil)
    }

}
