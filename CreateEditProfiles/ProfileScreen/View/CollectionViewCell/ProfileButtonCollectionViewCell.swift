//
//  ProfileButtonCollectionViewCell.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class ProfileButtonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var buttonImageView: UIImageView!
    
    var buttonType: ProfileButtonType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }
    
    func configure() {
        self.buttonView.backgroundColor = AppColor.primaryColor
        self.buttonView.layer.cornerRadius = self.buttonView.bounds.height/2
    }
}
