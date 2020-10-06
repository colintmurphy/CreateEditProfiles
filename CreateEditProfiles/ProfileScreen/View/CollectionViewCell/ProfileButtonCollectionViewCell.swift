//
//  ProfileButtonCollectionViewCell.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class ProfileButtonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var buttonLabel: UILabel!
    @IBOutlet private weak var buttonView: UIView!
    @IBOutlet private weak var buttonImageView: UIImageView!
    
    private var buttonType: ProfileButtonType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }
    
    func set(type: ProfileButtonType, label: String, image: UIImage) {
        self.buttonType = type
        self.buttonLabel.text = label
        self.buttonImageView.image = image
    }
    
    func getButtonType() -> ProfileButtonType? {
        return self.buttonType
    }
    
    private func configure() {
        
        self.buttonView.backgroundColor = AppColor.primaryColor
        self.buttonView.layer.cornerRadius = self.buttonView.bounds.height / 2
    }
}
