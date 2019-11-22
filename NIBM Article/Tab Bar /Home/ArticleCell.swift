//
//  ArticleCell.swift
//  NIBM Article
//
//  Created by Kithmal Bulathsinhala on 11/6/19.
//  Copyright © 2019 NIBM. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {

    
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDecription: UILabel!
    
    var User : String?
    
    // the delegate, remember to set to weak to prevent cycles
    weak var delegate : ArticleCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnAvatar.addTarget(self, action: #selector(btnAvatarClick(_:)), for: .touchUpInside)
    }

    
    @IBAction func btnAvatarClick(_ sender: Any) {
        if let user = User,
            let delegate = delegate {
            self.delegate?.avatarCell(self, avatarButtonTappedFor: user)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
protocol ArticleCellDelegate: AnyObject {
    func avatarCell(_ articleCell: ArticleCell, avatarButtonTappedFor user: String)
}
