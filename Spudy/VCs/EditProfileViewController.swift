//
//  EditProfileViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 10/12/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreData

class EditProfileViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var gradYearTextField: UITextField!
    @IBOutlet weak var contactInfoTextField: UITextField!
    @IBOutlet weak var currentClassesCollectionView: UICollectionView!
    
    let cellIdentifier = "editCurrClassesCellIdentiifer"
    var username = ""
    var photoURLString:String?
    var currClasses:[String] = []
    var toDeleteClassesIndices:[Int] = []
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUsername()
        
        currentClassesCollectionView.delegate = self
        currentClassesCollectionView.dataSource = self
        
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2

        // allow keyboard to toggle when text field not clicked on
        nameTextField.delegate = self
        majorTextField.delegate = self
        gradYearTextField.delegate = self
        contactInfoTextField.delegate = self
        
        // get the user's profile info
        ref = Database.database().reference(withPath: "profile")
        ref.observe(.value, with: { snapshot in
            // grab the data!
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: self.username) as? NSDictionary
            
            // get profile photo
            self.photoURLString = user?["photo"] as? String ?? nil
            if self.photoURLString != nil && self.photoURLString!.count != 0 {
                if let photoURL = URL(string: self.photoURLString!) {
                    if let data = try? Data(contentsOf: photoURL) {
                        self.profileImage.image = UIImage(data: data)
                    }
                }
            }
            
            //store file in database
            self.nameTextField.text = user?["name"] as? String ?? "Unknown"
            self.majorTextField.text = user?["major"] as? String ?? "Unknown"
            self.gradYearTextField.text = user?["gradYear"] as? String ?? "Unknown"
            
            let classes = user?["classes"] as? [String] ?? []
            self.currClasses.removeAll()
            self.currClasses.append(contentsOf: classes)
            self.contactInfoTextField.text = user?["contactInfo"] as? String ?? ""
            
            self.currentClassesCollectionView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.currentClassesCollectionView.reloadData()
    }
    
    func getUsername() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        // to store results of request
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            // get username of current person logged in
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
            username = fetchedResults?[0].value(forKey: "username") as! String
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currClasses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let labeledCell = cell as! EditClassesCollectionViewCell
        labeledCell.setText(newText: currClasses[indexPath.row])
        
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
      ) -> CGSize {
          let availableWidth = currentClassesCollectionView.frame.width - 20
          let widthPerItem = availableWidth / 3
        
          return CGSize(width: widthPerItem, height: 35)
      }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "addClassCollectionViewFooter", for: indexPath) as! AddClassCollectionReusableView
        print("getting reusable cell")
        return sectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = currentClassesCollectionView.cellForItem(at: indexPath)
        let statusCell = cell as! EditClassesCollectionViewCell
        statusCell.changeDeleteStatus()

        if !statusCell.getDeleteStatus() && cell != nil {
            cell!.contentView.backgroundColor = UIColor(red: 214.0 / 255.0, green: 218.0 / 255.0, blue: 1.0, alpha: 1.0)
            
            toDeleteClassesIndices.removeAll(where: { value in
                value == indexPath.row
            })
            
        } else if cell != nil {
            cell!.contentView.backgroundColor = UIColor(red: 1.0, green: 169.0 / 255.0, blue: 169.0 / 255.0, alpha: 1.0)
            toDeleteClassesIndices.append(indexPath.row)
        }
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func editPhotoButtonPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
                }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        profileImage.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addClassButtonPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Add class", message: "Type in the class you wish to add.", preferredStyle: .alert)
        
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
        
        present(controller, animated: true, completion: nil)
    }
    
    func saveNewClass(newClass: String) {
        currClasses.append(newClass)
        self.currentClassesCollectionView.reloadData()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        for indexToRemove in toDeleteClassesIndices.sorted(by: >) {
            currClasses.remove(at: indexToRemove)
        }
        
        let newItemRef = self.ref.child(username) // replace with username
        newItemRef.child("photo").setValue(photoURLString ?? "")
        newItemRef.child("name").setValue(nameTextField.text ?? "Unknown")
        newItemRef.child("major").setValue(majorTextField.text ?? "Unknown")
        newItemRef.child("gradYear").setValue(gradYearTextField.text ?? "Unknown")
        newItemRef.child("classes").setValue(currClasses)
        newItemRef.child("contactInfo").setValue(contactInfoTextField.text ?? "")
        
        print("tried to store to database")
    }
}
