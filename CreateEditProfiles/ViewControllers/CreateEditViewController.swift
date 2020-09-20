//
//  CreateEditViewController.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class CreateEditViewController: UIViewController {
    
    @IBOutlet weak var infoTable: UITableView!
    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var customBackground: UIView!
    @IBOutlet weak var photoButton: UIButton!
    
    weak var studentDelegate: UpdateStudentDelegate?
    var infoList: [(title: String, info: String)] = []
    var student: Student?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupInfo()
        self.setupTable()
    }
    
    // MARK: ACTIONS
    
    @IBAction func setPhoto(_ sender: Any) {
        self.showImagePickerControllerActionSheet()
    }
    
    @objc func cancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButton() {
        
        guard let firstNameCell = self.infoTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? InfoTableViewCell else { fatalError("Failed: First Name Cell") }
        guard let lastNameCell = self.infoTable.cellForRow(at: IndexPath(row: 1, section: 0)) as? InfoTableViewCell else { fatalError("Failed: Last Name Cell") }
        guard let phoneCell = self.infoTable.cellForRow(at: IndexPath(row: 2, section: 0)) as? InfoTableViewCell else { fatalError("Failed: Phone Cell") }
        guard let emailCell = self.infoTable.cellForRow(at: IndexPath(row: 3, section: 0)) as? InfoTableViewCell else { fatalError("Failed: Email Cell") }
        
        if let isValidFirstName = firstNameCell.cellInfoTextField.text?.isValidName(),
           let isValidLastName = lastNameCell.cellInfoTextField.text?.isValidName(),
           let isValidNumber = phoneCell.cellInfoTextField.text?.isValidPhoneNumber(),
           let isValidEmail = emailCell.cellInfoTextField.text?.isValidEmail()  {
            
            if !isValidFirstName {
                self.showAlert(title: "First Name", message: "Please make sure your first name only contains letters and is between 3 and 35 letters.")
            } else if !isValidLastName {
                self.showAlert(title: "Last Name", message: "Please make sure your last name only contains letters and is between 3 and 35 letters.")
            } else if !isValidNumber {
                self.showAlert(title: "Phone Number", message: "Please make sure your phone number only contains numbers and is between 8 and 12 digits.")
            } else if !isValidEmail {
                self.showAlert(title: "Email", message: "Please make sure your email is a valid email.")
            } else {
                if student == nil {
                    let student = Student(firstName:  firstNameCell.cellInfoTextField.text ?? "", lastName: lastNameCell.cellInfoTextField.text ?? "", phone: phoneCell.cellInfoTextField.text ?? "", email: emailCell.cellInfoTextField.text ?? "", profileImage: self.studentImageView.image ?? AppImage.defaultImage)
                    self.studentDelegate?.updateStudent(student: student, at: nil)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.student?.firstName = firstNameCell.cellInfoTextField.text ?? ""
                    self.student?.lastName = lastNameCell.cellInfoTextField.text ?? ""
                    self.student?.phone = phoneCell.cellInfoTextField.text ?? ""
                    self.student?.email = emailCell.cellInfoTextField.text ?? ""
                    self.student?.profileImage = self.studentImageView.image ?? AppImage.defaultImage
                    self.studentDelegate?.updateStudent(student: self.student, at: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: SETUP
    
    func setupInfo() {
        if let user = self.student {
            self.studentImageView.image = user.profileImage
            self.infoList.append(("First Name", user.firstName))
            self.infoList.append(("Last Name", user.lastName))
            self.infoList.append(("number", user.phone))
            self.infoList.append(("email", user.email))
            self.title = "Edit Student"
        } else {
            self.infoList.append(("First Name", ""))
            self.infoList.append(("Last Name", ""))
            self.infoList.append(("number", ""))
            self.infoList.append(("email", ""))
            self.title = "Add Student"
        }
    }
    
    func setupTable() {
        self.infoTable.register(UINib(nibName: NibId.infoTableCell, bundle: nil), forCellReuseIdentifier: CellId.infoTableCell)
        self.infoTable.allowsSelection = false
        self.infoTable.isScrollEnabled = false
        self.infoTable.tableFooterView = UIView()
        self.infoTable.reloadData()
    }
    
    func setupUI() {
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButton))
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButton))
        self.navigationItem.leftBarButtonItem = cancel
        self.navigationItem.rightBarButtonItem = done
        self.navigationController?.navigationBar.tintColor = AppColor.primaryColor
        
        self.photoButton.backgroundColor = AppColor.primaryColor
        self.photoButton.layer.cornerRadius = self.photoButton.bounds.height/2
        self.photoButton.contentVerticalAlignment = .fill
        self.photoButton.contentHorizontalAlignment = .fill
        self.photoButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        self.studentImageView.backgroundColor = .systemGray4
        self.studentImageView.layer.cornerRadius = self.studentImageView.bounds.height/2
        self.studentImageView.layer.borderWidth = 1.0
        self.studentImageView.layer.borderColor = UIColor.systemGray.cgColor
        
        self.customBackground.addGradient(to: self.customBackground, with: [0.0, 1.0])
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource

extension CreateEditViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellId.infoTableCell) as? InfoTableViewCell else { fatalError("Could not create InfoTableViewCell") }
        
        cell.cellLabel.text = self.infoList[indexPath.row].title
        cell.cellInfoTextField.text = self.infoList[indexPath.row].info
        cell.cellInfoTextField.clearButtonMode = .whileEditing
        
        if indexPath.row < 2  {
            cell.cellInfoTextField.keyboardType = .default
            cell.cellInfoTextField.autocapitalizationType = .words
        } else if indexPath.row == 2 {
            cell.cellInfoTextField.keyboardType = .phonePad
        } else if indexPath.row == 3 {
            cell.cellInfoTextField.keyboardType = .emailAddress
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
        } else if let originalImage = info[.originalImage] as? UIImage {
            self.studentImageView.image = originalImage
        } else {
            self.studentImageView.image = AppImage.defaultImage
        }
        self.dismiss(animated: true, completion: nil)
    }
}
