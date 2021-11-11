//
//  FriendsTableViewCell.swift
//  Spudy
//
//  Created by Lilly on 11/9/21.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePhoto?.layer.masksToBounds = true
        profilePhoto?.layer.cornerRadius = profilePhoto.bounds.width / 2
    }
    
    func setName(name: String) {
        nameLabel.text = name
    }
    
    func setUsername(username: String) {
        usernameLabel.text = "@\(username)"
    }
    
    func setPhoto(photo: UIImage) {
        profilePhoto.image = photo
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "FriendsTableViewCell", bundle: nil)
    }
    
}
