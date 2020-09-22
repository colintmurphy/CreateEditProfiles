//
//  InfoTableViewCell.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellInfoTextField: CustomTextField!
    
    weak var infoDelegate: InfoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func textDidChange(_ textField: CustomTextField) {
        self.infoDelegate?.didChangeInTextField(textField)
    }
}
