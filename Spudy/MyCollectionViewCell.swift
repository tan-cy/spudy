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
    
    @IBOutlet var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with image: UIImage) {
        imageView.image =  image
    }
    
    // tells collection view hey we have a cell use it
    static func nib() ->UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }

}
