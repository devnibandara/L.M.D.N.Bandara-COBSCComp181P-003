//
//  ProfileViewController.swift
//  NIBM Article
//
//  Created by Kithmal Bulathsinhala on 11/6/19.
//  Copyright © 2019 NIBM. All rights reserved.
//

import UIKit
import  FirebaseStorage
import FirebaseDatabase
import  SwiftyJSON
import Kingfisher

class ProfileViewController: UIViewController {
    var imagePicker: ImagePicker!

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtFName: UITextField!
    @IBOutlet weak var txtLName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    
    
    @IBAction func btnChangeImage(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func txtBirthday(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.datePickerDone))
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        sender.inputAccessoryView = toolBar
    }
    
    @objc func datePickerDone() {
        txtDOB.resignFirstResponder()
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        
        txtDOB.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "LoggedUser")
        UserDefaults.standard.removeObject(forKey: "LoggedIn")
        UserDefaults.standard.removeObject(forKey: "UserUID")
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnUpdate(_ sender: Any) {
        
        
        
        guard let FName = txtFName.text, !FName.isEmpty else {
            showAlert(message: "First Name cannot be empty")
            return
        }
        
        guard let LName = txtLName.text, !LName.isEmpty else {
            showAlert(message: "Last Name cannot be empty")
            return
        }
        
        guard let PhoneNumber = txtPhone.text, !PhoneNumber.isEmpty else {
            showAlert(message: "Number cannot be empty")
            return
        }
        
        guard let DOB = txtDOB.text, !DOB.isEmpty else {
            showAlert(message: "Number cannot be empty")
            return
        }
        
        let loggedUserUid = UserDefaults.standard.string(forKey: "UserUID")
        let loggedUserEmail = UserDefaults.standard.string(forKey: "LoggedUser")
        
        guard let image = imgProfile.image,
            let imgData = image.jpegData(compressionQuality: 1.0) else {
                showAlert(message: "An Image must be selected")
                return
        }
        
        let imageName = UUID().uuidString
        
        let reference = Storage.storage().reference().child("profileImages").child(imageName)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        
        reference.putData(imgData, metadata: metaData) { (meta, err) in
            if let err = err {
                self.showAlert(message: "Error uploading image: \(err.localizedDescription)")
                return
            }
            
            reference.downloadURL { (url, err) in
                if let err = err {
                    self.showAlert(message: "Error fetching url: \(err.localizedDescription)")
                    return
                }
                
                guard let url = url else {
                    self.showAlert(message: "Error getting url")
                    return
                }
                
                let imgUrl = url.absoluteString
                
                //                let dbChildName = UUID().uuidString
                
                
                let dbRef = Database.database().reference().child("users").child(loggedUserUid!)
                
                
                let data = [
                    "First_Name" : FName,
                    "Last_Name" : LName,
                    "profileImageUrl" : imgUrl,
                    "DOB" : DOB,
                    "Phone_Number" : PhoneNumber,
                    "Email" : loggedUserEmail
                    
                ]
                
                dbRef.setValue(data, withCompletionBlock: { ( err , dbRef) in
                    if let err = err {
                        self.showAlert(message: "Error uploading data: \(err.localizedDescription)")
                        return
                    }
                    self.showAlert(message: "Successfully Updated")
                    
                })
                
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        let loggedUserUid = UserDefaults.standard.string(forKey: "UserUID")
        let ref = Database.database().reference().child("users").child(loggedUserUid!)
        ref.observe(.value, with: { snapshot in
            
            let dict = snapshot.value as? [String: AnyObject]
            let json = JSON(dict as Any)
            
            let imageURL = URL(string: json["profileImageUrl"].stringValue)
            self.imgProfile.kf.setImage(with: imageURL)
            
            self.txtFName.text = json["First_Name"].stringValue
            self.txtLName.text = json["Last_Name"].stringValue
            self.txtDOB.text = json["DOB"].stringValue
            self.txtPhone.text = json["Phone_Number"].stringValue
        })
    }
    

    func showAlert(message:String)
    {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

}
extension ProfileViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.imgProfile.image = image
    }
}
