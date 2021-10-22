//
//  EditClassesCollectionViewCell.swift
//  Spudy
//
//  Created by Lilly on 10/19/21.
//

import UIKit

class EditClassesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var classesLabel: UILabel!
    var willDelete:Bool = false
    
    func setText(newText: String) {
        classesLabel!.text = newText
    }
    
    func changeDeleteStatus() {
        willDelete = !willDelete
    }
    
    func getDeleteStatus() -> Bool {
        return willDelete
    }
}
