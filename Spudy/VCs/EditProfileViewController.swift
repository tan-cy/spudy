//
//  EditProfileViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 10/12/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import CoreData
import AVFoundation

class EditProfileViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var gradYearTextField: UITextField!
    @IBOutlet weak var contactInfoTextField: UITextField!
    @IBOutlet weak var currentClassesCollectionView: UICollectionView!
    
    let cellIdentifier = "editCurrClassesCellIdentiifer"
    var photoURLString:String?
    
    var currClasses:[String] = []
    var oldClasses:[String] = []
    var toDeleteClassesIndices:[Int] = []
    
    var profileRef: DatabaseReference!
    var classesRef: DatabaseReference!
    
    let imagePicker = UIImagePickerController()
    var changedPhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        currentClassesCollectionView.delegate = self
        currentClassesCollectionView.dataSource = self
        imagePicker.delegate = self
        
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2

        // allow keyboard to toggle when text field not clicked on
        nameTextField.delegate = self
        majorTextField.delegate = self
        gradYearTextField.delegate = self
        contactInfoTextField.delegate = self
        
        // get database reference to classes
        classesRef = Database.database().reference(withPath: Constants.DatabaseKeys.classesPath)
        
        // get the user's profile info
        profileRef = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
        profileRef.observe(.value, with: { snapshot in
            // grab the data!
            let value = snapshot.value as? NSDictionary
            let user = value?.value(forKey: CURRENT_USERNAME) as? NSDictionary
            
            // get profile photo
            let urlString = user?[Constants.DatabaseKeys.photo] as? NSString
            if urlString != nil && urlString!.length != 0,
                let photoURL = URL(string: urlString! as String),
                let data = try? Data(contentsOf: photoURL) {
                    self.profileImage.image = UIImage(data: data)
            } else {
                self.profileImage.image = UIImage(systemName: "person.circle.fill")
            }
            
            //store file in database
            self.nameTextField.text = user?[Constants.DatabaseKeys.name] as? String ?? "Unknown"
            self.majorTextField.text = user?[Constants.DatabaseKeys.major] as? String ?? "Unknown"
            self.gradYearTextField.text = user?[Constants.DatabaseKeys.gradYear] as? String ?? "Unknown"
            
            let classes = user?[Constants.DatabaseKeys.classes] as? [String] ?? []
            self.currClasses.removeAll()
            self.currClasses.append(contentsOf: classes)
            self.oldClasses.removeAll()
            self.oldClasses.append(contentsOf: classes)

            self.contactInfoTextField.text = user?[Constants.DatabaseKeys.contactInfo] as? String ?? ""
            
            self.currentClassesCollectionView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.currentClassesCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currClasses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let labeledCell = cell as! EditClassesCollectionViewCell
        labeledCell.setText(newText: currClasses[indexPath.row])
        
        // determine what color the cell is
        if toDeleteClassesIndices.contains(indexPath.row) {
            cell.contentView.backgroundColor = UIColor(red: 1.0, green: 169.0 / 255.0, blue: 169.0 / 255.0, alpha: 1.0)
        } else {
            cell.contentView.backgroundColor = UIColor(red: 214.0 / 255.0, green: 218.0 / 255.0, blue: 1.0, alpha: 1.0)
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = currentClassesCollectionView.cellForItem(at: indexPath)
        
        let statusCell = cell as! EditClassesCollectionViewCell
        
        statusCell.changeRemoveStatus()
        
        if statusCell.willBeRemoved() {
            cell!.contentView.backgroundColor = UIColor(red: 1.0, green: 169.0 / 255.0, blue: 169.0 / 255.0, alpha: 1.0)
            
            toDeleteClassesIndices.append(indexPath.row)
        } else {
            cell!.contentView.backgroundColor = UIColor(red: 214.0 / 255.0, green: 218.0 / 255.0, blue: 1.0, alpha: 1.0)

            toDeleteClassesIndices.removeAll(where: { value in
                value == indexPath.row
            })
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
        // show actionsheet allowing user to choose between uploading a photo or taking a photo
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.takePhotoPressed()
        })
        alert.addAction(UIAlertAction(title: "Upload Photo", style: .default) { _ in
            self.uploadPhotoPressed()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func takePhotoPressed() {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil  {
            
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) {
                    accessGranted in
                    guard accessGranted == true else { return }
                }
            case .authorized:
                break
            default:
                let alert = UIAlertController(title: "Please Grant Access", message: "Our app currently does not have permission to use your camera.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera Not Found", message: "Our app could not find a camera on your device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func uploadPhotoPressed() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        profileImage.image = image
        self.dismiss(animated: true, completion: {
            self.changedPhoto = true
        })
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
                    let formattedClass = self.formatClassCode(newClass: enteredText!)
                    self.saveNewClass(newClass: formattedClass)                    
                }
            }
        }))
        
        present(controller, animated: true, completion: nil)
    }
    
    func formatClassCode(newClass: String) -> String {
        let unformattedText = newClass
        
        // find where the numbered part of the class code starts
        var classNumberCodeIndex = -1
        for (index, character) in unformattedText.enumerated() {
            if "0123456789".contains(character) {
                classNumberCodeIndex = index
                break
            }
        }
        
        if classNumberCodeIndex != -1 {
            let index = unformattedText.index(unformattedText.startIndex, offsetBy: classNumberCodeIndex)
            
            let spaceIndex = unformattedText.index(unformattedText.startIndex, offsetBy: classNumberCodeIndex - 1)
            
            // check if there already is a space after the department code
            var classDepartment = unformattedText[..<index]
            classDepartment = classDepartment[spaceIndex] == " " ? classDepartment[..<spaceIndex] : classDepartment
            // uppercase the department code (man -> MAN)
            let finalClassDepartment = classDepartment.uppercased()
            
            let numberCode = unformattedText[index...]
            let finalNumberCode = numberCode.uppercased()
            
            return "\(finalClassDepartment) \(finalNumberCode)"
        
        } else {
            // can't really do much to format this
            return unformattedText
        }
    }
    
    func saveNewClass(newClass: String) {
        currClasses.append(newClass)
        self.currentClassesCollectionView.reloadData()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        for indexToRemove in toDeleteClassesIndices.sorted(by: >) {
            currClasses.remove(at: indexToRemove)
        }
        
        let newItemRef = self.profileRef.child(CURRENT_USERNAME) // replace with username
//        newItemRef.child("photo").setValue(profileImage.image ?? nil)
        newItemRef.child("name").setValue(nameTextField.text ?? "Unknown")
        newItemRef.child("major").setValue(majorTextField.text ?? "Unknown")
        newItemRef.child("gradYear").setValue(gradYearTextField.text ?? "Unknown")
        newItemRef.child("classes").setValue(currClasses)
        newItemRef.child("contactInfo").setValue(contactInfoTextField.text ?? "")
        
        if self.changedPhoto {
            saveProfilePhotoData()
        }

        // reset
        toDeleteClassesIndices.removeAll()
        
        updateUsersInClasses()
        
        let successAlert = UIAlertController(title: "Success!", message: "Your changes have been saved.", preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(successAlert, animated: true, completion: nil)
    }
    
    func updateUsersInClasses() {
        let difference = currClasses.difference(from: oldClasses)
        
        var newClasses: [String] = []
        var removedClasses: [String] = []
        
        for diff in difference {
            if case let .insert(_, element, _) = diff {
                newClasses.append(element)
            }
            if case let .remove(_, element, _) = diff {
                removedClasses.append(element)
            }
        }
        
        newClasses.forEach { newClass in
            self.classesRef.getData(completion: {_, snapshot in
                
                let value = snapshot.value as? NSDictionary
                let classValue = value?.value(forKey: newClass) as? NSDictionary
                var students = classValue?.value(forKey: Constants.DatabaseKeys.students) as? [String] ?? []
                
                students.append(CURRENT_USERNAME)
                self.classesRef.child(newClass).child(Constants.DatabaseKeys.students).setValue(students)
            })
        }
        
        removedClasses.forEach { removeClass in
            self.classesRef.getData(completion: {error, snapshot in
                guard error == nil else {
                    return
                }
                
                let value = snapshot.value as? NSDictionary
                let classValue = value?.value(forKey: removeClass) as? NSDictionary
                var students = classValue?.value(forKey: Constants.DatabaseKeys.students) as? [String] ?? []
                
                students = students.filter() {$0 != CURRENT_USERNAME}
                self.classesRef.child(removeClass).child(Constants.DatabaseKeys.students).setValue(students)
            })
        }
        
    }
    
    func saveProfilePhotoData() {
        guard let image = profileImage.image, let data = image.jpegData(compressionQuality: 0.3) else {
            // alert something went wrong
            return
        }
        
        let md = StorageMetadata()
        md.contentType = "image/png"
        
        let imageName = UUID().uuidString
        let imageReference = Storage.storage().reference().child("profileImages").child(CURRENT_USERNAME).child(imageName)
        
        imageReference.putData(data, metadata: md) {
            (metadata, error) in
            
            // upload didn't work? show error
            if let error = error {
                let alert = UIAlertController(title: "Error Uploading Image", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // need to save url now
            imageReference.downloadURL(completion: {
                (url, _) in
                
                guard let url = url else {
                    return
                }
                
                let urlString = url.absoluteString
                
                self.profileRef.child(CURRENT_USERNAME).child(Constants.DatabaseKeys.photo).setValue(urlString)
            })
        }
        
    }
    
}
