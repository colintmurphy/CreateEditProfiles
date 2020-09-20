//
//  UserTableViewCell.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var studentNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure() {
        self.profileImage.backgroundColor = .systemGray4
        self.profileImage.layer.borderWidth = 1
        self.profileImage.layer.borderColor = UIColor.systemGray.cgColor
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.height/2
    }
}
