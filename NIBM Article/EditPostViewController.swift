//
//  EditPostViewController.swift
//  NIBM Article
//
//  Created by Kithmal Bulathsinhala on 11/6/19.
//  Copyright © 2019 NIBM. All rights reserved.
//

import UIKit
import SwiftyJSON
import FirebaseDatabase
import Kingfisher
import FirebaseStorage

class EditPostViewController: UIViewController {
    
    var imagePicker: ImagePicker!
    var avatarImageUrl: String!
    var article: JSON?
    var articleID: String?
    
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        txtTitle.text = article!["title"].stringValue
        txtDescription.text = article!["description"].stringValue
        
        let imageURL = URL(string: article!["imageUrl"].stringValue)
        imgPhoto.kf.setImage(with: imageURL)
    }
    
    @IBAction func btnUpdate(_ sender: Any) {
        
        
        let loggedUserUID = UserDefaults.standard.string(forKey: "UserUID")
        
        let avatarRef = Database.database().reference().child("users").child(loggedUserUID!)
        avatarRef.observe(.value, with: { snapshot in
            
            let dict = snapshot.value as? [String: AnyObject]
            let json = JSON(dict as Any)
            
            self.avatarImageUrl = json["profileImageUrl"].stringValue
            
            
            
        })
        
        guard let Title = txtTitle.text, !Title.isEmpty else {
            showAlert(message: "Title cannot be empty")
            return
        }
        
        guard let Description = txtDescription.text, !Description.isEmpty else {
            showAlert(message: "Description cannot be empty")
            return
        }
        
        
        guard let image = imgPhoto.image,
            let imgData = image.jpegData(compressionQuality: 1.0) else {
                showAlert(message: "An Image must be selected")
                return
        }
        
        let imageName = UUID().uuidString
        
        let reference = Storage.storage().reference().child("articleImages").child(imageName)
        
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

                
                
                let dbRef = Database.database().reference().child("articles").child("allArticles").child(self.articleID!)
                
                
                let data = [
                    "title" : Title,
                    "description" : Description,
                    "imageUrl" : imgUrl,
                    "userUID" : loggedUserUID,
                    "userAvatarImageUrl" : self.avatarImageUrl
                ]
                
                dbRef.setValue(data, withCompletionBlock: { ( err , dbRef) in
                    if let err = err {
                        self.showAlert(message: "Error uploading data: \(err.localizedDescription)")
                        return
                    }
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController")
                    self.present(vc, animated: true, completion: nil)
                    
                })
                
            }
            
        }
        
    }


    func showAlert(message:String)
    {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

}
extension EditPostViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.imgPhoto.image = image
    }
}
