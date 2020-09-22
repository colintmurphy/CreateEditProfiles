//
//  UserTableViewCell.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var studentNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure() {
        self.profileImageView.backgroundColor = .systemGray4
        self.profileImageView.layer.borderWidth = 1
        self.profileImageView.layer.borderColor = UIColor.systemGray.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height/2
    }
}
