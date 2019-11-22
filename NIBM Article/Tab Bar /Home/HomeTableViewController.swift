//
//  HomeTableViewController.swift
//  NIBM Article
//
//  Created by Kithmal Bulathsinhala on 11/6/19.
//  Copyright © 2019 NIBM. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftyJSON
import Kingfisher

class HomeTableViewController: UITableViewController {
    
    private var articleIDs = [String]()
    private var items = [JSON](){
        didSet{
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
        
        let ref = Database.database().reference().child("articles")
        ref.observe(.value, with: { snapshot in
            self.items.removeAll()
            self.articleIDs.removeAll()
            let dict = snapshot.value as? [String: AnyObject]
            let json = JSON(dict as Any)
            
            for object in json["allArticles"]{
                self.articleIDs.append(object.0)
                self.items.append(object.1)
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)  as! ArticleCell

        cell.txtTitle.text = items[indexPath.row]["title"].stringValue
        cell.txtDecription.text = items[indexPath.row]["description"].stringValue
        
        
        let imageURL = URL(string: items[indexPath.row]["imageUrl"].stringValue)
        cell.imgPhoto.kf.setImage(with: imageURL)
        
        let avatarImageURL = URL(string: items[indexPath.row]["userAvatarImageUrl"].stringValue)
        cell.btnAvatar.kf.setImage(with: avatarImageURL, for: .normal)
        cell.btnAvatar.kf.setBackgroundImage(with: avatarImageURL, for: .normal)
        
        cell.User = items[indexPath.row]["userUID"].stringValue
        
        cell.delegate = self

        return cell
    }
    
    ////////////////////////////////////////////////////////////////
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //print("ereerererer")
        let loggedUserUid = UserDefaults.standard.string(forKey: "UserUID")
        let tempUID = items[indexPath.row]["userUID"].stringValue
        if loggedUserUid == tempUID{
            let vc = EditPostViewController(nibName: "EditPostViewController", bundle: nil)
            
            vc.article = items[indexPath.row]
            vc.articleID = articleIDs[indexPath.row]
            
            navigationController?.pushViewController(vc, animated: true)
        }
        else{
            let vc = ViewArticleViewController(nibName: "ViewArticleViewController", bundle: nil)
            vc.article = items[indexPath.row]
            print("ereerererer")
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 270
    }
 

    func showAlert(message:String)
    {
        
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
extension HomeTableViewController : ArticleCellDelegate {
    func avatarCell(_ articleCell: ArticleCell, avatarButtonTappedFor user: String) {
        
        let vc = UserViewController(nibName: "UserViewController", bundle: nil)
        vc.UID = user
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}
