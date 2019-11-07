//
//  PostArticleViewController.swift
//  NIBM Article
//
//  Created by Kithmal Bulathsinhala on 11/6/19.
//  Copyright © 2019 NIBM. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import SwiftyJSON

class PostArticleViewController: UIViewController {

    var imagePicker: ImagePicker!
    var avatarImageUrl: String!
    
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    

    @IBAction func AddImage(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func btnUploadArticle(_ sender: Any) {

        let loggedUserUID = UserDefaults.standard.string(forKey: "UserUID")
        
        let avatarRef = Database.database().reference().child("users").child(loggedUserUID!)
        avatarRef.observe(.value, with: { snapshot in
            
            let dict = snapshot.value as? [String: AnyObject]
            let json = JSON(dict as Any)
            
            self.avatarImageUrl = json["profileImageUrl"].stringValue
            
            
            
        })
        
        guard let title = txtTitle.text, !title.isEmpty else {
            showAlert(message: "Title cannot be empty")
            return
        }
        
        guard let description = txtDescription.text, !description.isEmpty else {
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
                
                //                let dbChildName = UUID().uuidString
                
                
                let dbRef = Database.database().reference().child("articles").child("allArticles").childByAutoId()
                
                
                let data = [
                    "title" : title,
                    "description" : description,
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

extension PostArticleViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.imgPhoto.image = image
    }
}
