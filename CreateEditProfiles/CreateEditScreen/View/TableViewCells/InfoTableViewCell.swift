//
//  InfoTableViewCell.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var cellLabel: UILabel!
    @IBOutlet weak var cellInfoTextField: CustomTextField!
    
    weak var infoDelegate: InfoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction private func textDidChange(_ textField: CustomTextField) {
        self.infoDelegate?.didChangeInTextField(textField)
    }
    
    func setupProfileViewInfo(label: String, info: String) {
        
        self.cellLabel.text = label
        self.cellInfoTextField.text = info
        self.cellInfoTextField.isUserInteractionEnabled = false
    }
    
    func setupCreateInfo(type: TextFieldType, title: String, student: Student) {
        
        self.cellLabel.text = title
        self.cellInfoTextField.fieldType = type
        self.cellInfoTextField.keyboardType = .default
        self.cellInfoTextField.clearButtonMode = .whileEditing
        self.cellInfoTextField.autocapitalizationType = .words
        self.cellInfoTextField.accessibilityIdentifier = "name"
        
        switch type {
        case .firstName:
            self.cellInfoTextField.text = student.firstName
        case .lastName:
            self.cellInfoTextField.text = student.lastName
        case .email:
            self.cellInfoTextField.keyboardType = .emailAddress
            self.cellInfoTextField.autocapitalizationType = .none
            self.cellInfoTextField.accessibilityIdentifier = "email"
            self.cellInfoTextField.text = student.email
        case .phone:
            self.cellInfoTextField.keyboardType = .phonePad
            self.cellInfoTextField.accessibilityIdentifier = "phone"
            self.cellInfoTextField.text = student.phone
        }
    }
}
