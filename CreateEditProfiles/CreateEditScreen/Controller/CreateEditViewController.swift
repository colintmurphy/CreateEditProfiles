//
//  CreateEditViewController.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class CreateEditViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var infoTable: UITableView!
    @IBOutlet private weak var studentImageView: UIImageView!
    @IBOutlet private weak var customBackgroundView: UIView!
    @IBOutlet private weak var photoButton: UIButton!
    
    // MARK: - Class Variables
    
    var student: Student?
    weak var studentDelegate: UpdateStudentDelegate?
    private var activeTextField: UITextField?
    private var infoList: [(title: String, info: String, type: TextFieldType)] = []
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setupUI()
        self.setupInfo()
        self.setupTable()
    }
    
    // MARK: - ACTIONS
    
    @IBAction private func setPhoto(_ sender: Any) {
        self.showImagePickerControllerActionSheet()
    }
    
    @objc private func cancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButton() {
        
        if let isValidFirstName = student?.firstName.isValidName(),
           let isValidLastName = student?.lastName.isValidName(),
           let isValidNumber = student?.phone.isValidPhoneNumber(),
           let isValidEmail = student?.email.isValidEmail() {
            
            if !isValidFirstName {
                self.showAlert(title: "First Name", message: "Please make sure your first name only contains letters and is between 3 and 35 letters.")
            } else if !isValidLastName {
                self.showAlert(title: "Last Name", message: "Please make sure your last name only contains letters and is between 3 and 35 letters.")
            } else if !isValidNumber {
                self.showAlert(title: "Phone Number", message: "Please make sure your phone number only contains numbers and is between 8 and 12 digits.")
            } else if !isValidEmail {
                self.showAlert(title: "Email", message: "Please make sure your email is a valid email.")
            } else {
                self.studentImageView.image = student?.profileImage
                self.studentDelegate?.updateStudent(student: student, at: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - SETUP
    
    private func setupInfo() {
        
        if let user = self.student {
            self.studentImageView.image = user.profileImage
            self.infoList.append(("First Name", user.firstName, type: TextFieldType.firstName))
            self.infoList.append(("Last Name", user.lastName, type: TextFieldType.lastName))
            self.infoList.append(("number", user.phone, type: TextFieldType.phone))
            self.infoList.append(("email", user.email, type: TextFieldType.email))
            self.title = "Edit Student"
        } else {
            self.infoList.append(("First Name", "", type: TextFieldType.firstName))
            self.infoList.append(("Last Name", "", type: TextFieldType.lastName))
            self.infoList.append(("number", "", type: TextFieldType.phone))
            self.infoList.append(("email", "", type: TextFieldType.email))
            self.title = "Add Student"
            self.student = Student(firstName: "", lastName: "", phone: "", email: "", profileImage: AppImage.defaultImage)
        }
    }
    
    private func setupTable() {
        
        self.infoTable.register(UINib(nibName: NibId.infoTableCell, bundle: nil), forCellReuseIdentifier: CellId.infoTableCell)
        self.infoTable.allowsSelection = false
        self.infoTable.isScrollEnabled = false
        self.infoTable.tableFooterView = UIView()
        self.infoTable.reloadData()
    }
    
    private func setupUI() {
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButton))
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButton))
        self.navigationItem.leftBarButtonItem = cancel
        self.navigationItem.rightBarButtonItem = done
        self.navigationController?.navigationBar.tintColor = AppColor.primaryColor
        self.customBackgroundView.addGradient(to: self.customBackgroundView, with: [0.0, 1.0])
        
        self.photoButton.backgroundColor = AppColor.primaryColor
        self.photoButton.layer.cornerRadius = self.photoButton.bounds.height/2
        self.photoButton.contentVerticalAlignment = .fill
        self.photoButton.contentHorizontalAlignment = .fill
        self.photoButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        self.studentImageView.backgroundColor = .systemGray4
        self.studentImageView.layer.cornerRadius = self.studentImageView.bounds.height/2
        self.studentImageView.layer.borderWidth = 1.0
        self.studentImageView.layer.borderColor = UIColor.systemGray.cgColor
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // MARK: - Keyboard
    
    @objc private func dismissKeyboard() {
        
        self.infoTable.contentOffset = .zero
        self.activeTextField = nil
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if let textField = self.activeTextField,
               let tableViewRect = textField.superview?.superview?.frame {
                
                self.infoTable.contentInset = UIEdgeInsets(top: self.infoTable.contentInset.top, left: 0, bottom: keyboardSize.height, right: 0)
                self.infoTable.scrollRectToVisible(tableViewRect, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension CreateEditViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellId.infoTableCell) as? InfoTableViewCell else { fatalError("Could not create InfoTableViewCell") }
        
        cell.infoDelegate = self
        cell.cellInfoTextField.delegate = self
        
        if let student = self.student {
            cell.setupCreateInfo(type: self.infoList[indexPath.row].type, title: self.infoList[indexPath.row].title, student: student)
        }
        
        return cell
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CreateEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func showImagePickerControllerActionSheet() {
        
        let alert = UIAlertController(title: "Choose an image", message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Choose from library", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (action) in
            self.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraAction.isEnabled = false
        }
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            self.studentImageView.image = editedImage
            self.student?.update(withImage: editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            self.studentImageView.image = originalImage
            self.student?.update(withImage: originalImage)
        } else {
            self.studentImageView.image = AppImage.defaultImage
            self.student?.update(withImage: AppImage.defaultImage)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension CreateEditViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // if deleting: allow it
        if range.lowerBound+1 == range.upperBound { return true }
        
        if textField.accessibilityIdentifier == "name" {
            if textField.text?.count ?? 0 >= 25 { return false }
            
        } else if textField.accessibilityIdentifier == "phone" {
            if textField.text?.count ?? 0 >= 12 { return false }
            if string != "+" && Int(string) == nil { return false }
            
        } else if textField.accessibilityIdentifier == "email" {
            if string == " " || textField.text?.count ?? 0 >= 60 && range.upperBound < 61 { return false }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}

// MARK: - InfoTableViewCellDelegate

extension CreateEditViewController: InfoTableViewCellDelegate {
    
    func didChangeInTextField(_ textField: CustomTextField) {
        
        guard let text = textField.text else { return }
        
        switch textField.fieldType {
        case .firstName:
            self.student?.firstName = text
        case .lastName:
            self.student?.lastName = text
        case .email:
            self.student?.email = text
        case .phone:
            self.student?.phone = text
        case .none:
            break
        }
    }
}
