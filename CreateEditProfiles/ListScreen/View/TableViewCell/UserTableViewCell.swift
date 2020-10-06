//
//  UserTableViewCell.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var studentNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(name: String, image: UIImage) {
        
        self.studentNameLabel.text = name
        self.profileImageView.image = image
    }
    
    private func configure() {

        if #available(iOS 13.0, *) {
            self.profileImageView.backgroundColor = .systemGray4
        } else {
            self.profileImageView.backgroundColor = .gray
        }
        self.profileImageView.layer.borderWidth = 1
        self.profileImageView.layer.borderColor = UIColor.systemGray.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2
    }
}
