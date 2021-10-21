//
//  AddClassCollectionReusableView.swift
//  Spudy
//
//  Created by Lilly on 10/19/21.
//

import UIKit
import FirebaseDatabase

class AddClassCollectionReusableView: UICollectionReusableView {
    
    @IBAction func addClassButtonPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Add class", message: "Type in the class abbreviation. (For example: \"CS 371L\"", preferredStyle: .alert)
        
        controller.addTextField(configurationHandler: {
            (textField:UITextField!) in textField.placeholder = "Enter a class"
        })
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        controller.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            (paramAction:UIAlertAction!) in
            
            if let textFieldArray = controller.textFields {
                let textFields = textFieldArray as [UITextField]
                let enteredText = textFields[0].text
                if enteredText != nil {
                    self.saveNewClass(newClass: enteredText!)
                }
                
            }
        }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
//       present
    }
    
    func saveNewClass(newClass: String) {
        print("will save new class!")
    }
}
