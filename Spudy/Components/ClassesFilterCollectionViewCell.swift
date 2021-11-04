//
//  ClassesFilterCollectionViewCell.swift
//  Spudy
//
//  Created by Lilly on 11/2/21.
//

import UIKit

class ClassesFilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var checkboxImage: UIImageView!
    
    var isChecked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        isChecked = false
    }
    
    func getText() -> String {
        return classLabel.text ?? ""
    }
    
    func getCheckedStatus() -> Bool {
        return isChecked
    }
    
    func setText(newText: String) {
        classLabel?.text = newText
    }
    
    func checkBox() {
        if isChecked {
            // uncheck the box
            checkboxImage.image = UIImage(systemName: "square")
        } else {
            // check the box
            checkboxImage.image = UIImage(systemName: "checkmark.square.fill")
        }
        
        isChecked = !isChecked
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "ClassesFilterCollectionViewCell", bundle: nil)
    }

}
