//
//  ViewArticleViewController.swift
//  NIBM Article
//
//  Created by Kithmal Bulathsinhala on 11/7/19.
//  Copyright © 2019 NIBM. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class ViewArticleViewController: UIViewController {
    
    @IBOutlet weak var btnAvatar: UIButton!
    
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var txtTitle: UILabel!
    
    @IBOutlet weak var txtDescription: UILabel!
    
    var article: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtTitle.text = article!["title"].stringValue
        txtDescription.text = article!["description"].stringValue
        
        let imageURL = URL(string: article!["imageUrl"].stringValue)
        imgPhoto.kf.setImage(with: imageURL)
        
        let avatarURL = URL(string: article!["userAvatarImageUrl"].stringValue)
        btnAvatar.kf.setImage(with: avatarURL, for: .normal)
        btnAvatar.kf.setBackgroundImage(with: avatarURL, for: .normal)
    }
    
    
    @IBAction func btnAvatar(_ sender: Any) {
        let vc = UserViewController(nibName: "UserViewController", bundle: nil)
        vc.UID = article!["userUID"].stringValue
        
        navigationController?.pushViewController(vc, animated: true)
    }
    


}
