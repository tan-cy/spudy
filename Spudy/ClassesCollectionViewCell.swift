//
//  ClassesCollectionViewCell.swift
//  Spudy
//
//  Created by Lilly on 10/18/21.
//

import UIKit

class ClassesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var classesLabel: UILabel!
    
    func setText(newText: String) {
        classesLabel!.text = newText
    }
    
}
