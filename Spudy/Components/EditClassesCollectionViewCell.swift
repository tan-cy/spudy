//
//  EditClassesCollectionViewCell.swift
//  Spudy
//
//  Created by Lilly on 10/19/21.
//

import UIKit

class EditClassesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var classesLabel: UILabel!
    var toRemove: Bool = false
    
    func setText(newText: String) {
        classesLabel!.text = newText
    }
    
    func changeRemoveStatus() {
        toRemove = !toRemove
    }
    
    func willBeRemoved() -> Bool {
        return toRemove
    }
}
