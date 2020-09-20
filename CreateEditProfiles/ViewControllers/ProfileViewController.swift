//
//  ProfileViewController.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit
import MessageUI

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var infoTable: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var customBackground: UIView!
    @IBOutlet weak var buttonCollectionView: UICollectionView!
    
    var infoList: [(title: String, info: String)] = []
    var buttons: [(title: String, image: UIImage)] = []
    var student: Student?
    var studentIndex: (section:String, row:Int)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupInfo()
        self.setupTable()
    }
    
    // MARK: ACTIONS
    
    @IBAction func editBarButton(_ sender: Any) {
        let sb = UIStoryboard.init(name: StoryboardId.main, bundle: nil)
        if let vc = sb.instantiateViewController(identifier: StoryboardId.createEditVC) as? CreateEditViewController {
            vc.student = self.student
            vc.studentDelegate = self
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func callUser() {
        if let phone = self.student?.phone
        {
            if let url = URL(string: "tel://+\(phone)"),
            UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                self.showAlert(title: "Sorry", message: "Looks like we could not process your phone call at this time.")
            }
        }
    }
    
    func emailUser() {
        guard MFMailComposeViewController.canSendMail() else {
            self.showAlert(title: "Sorry", message: "Looks like we could not process your email at this time.")
            return
        }
        if let email = self.student?.email {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([email])
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    func messageUser() {
        guard MFMessageComposeViewController.canSendText() else {
            self.showAlert(title: "Sorry", message: "Looks like we could not process your message at this time.")
            return
        }
        if let phone = self.student?.phone {
            let messageComposer = MFMessageComposeViewController()
            messageComposer.messageComposeDelegate = self
            messageComposer.recipients = [phone]
            self.present(messageComposer, animated: true, completion: nil)
        }
    }
    
    // MARK: SETUP
    
    func setupInfo() {
        if let user = self.student {
            self.nameLabel.text = "\(user.firstName) \(user.lastName)"
            self.studentImage.image = user.profileImage
            self.infoList.append(("mobile", user.phone))
            self.infoList.append(("email", user.email))
        }
        self.buttons.append((title: "message", image: AppImage.message))
        self.buttons.append((title: "call", image: AppImage.call))
        self.buttons.append((title: "email", image: AppImage.email))
    }
    
    func setupTable() {
        self.infoTable.register(UINib(nibName: NibId.infoTableCell, bundle: nil), forCellReuseIdentifier: CellId.infoTableCell)
        self.infoTable.allowsSelection = false
        self.infoTable.isScrollEnabled = false
        self.infoTable.tableFooterView = UIView()
        self.infoTable.reloadData()
        
        self.buttonCollectionView.register(UINib(nibName: NibId.profileCollectionCell, bundle: nil), forCellWithReuseIdentifier: CellId.profileCollectionCell)
        self.buttonCollectionView.reloadData()
    }
    
    func setupUI() {
        self.studentImage.layer.cornerRadius = self.studentImage.bounds.height/2
        self.studentImage.backgroundColor = .systemGray4
        self.studentImage.layer.borderWidth = 1
        self.studentImage.layer.borderColor = UIColor.systemGray.cgColor
        self.customBackground.addGradient(to: self.customBackground, with: [0.25, 1.0])
    }
}

// MARK: - UpdateUserProtocol

extension ProfileViewController: UpdateStudentDelegate {
    
    func updateStudent(student: Student?, at index: (section:String, row:Int)?) {
        
        if let user = student {
            self.student = user
            self.nameLabel.text = "\(user.firstName) \(user.lastName)"
            self.studentImage.image = user.profileImage
            self.infoList[0].info = user.phone
            self.infoList[1].info = user.email
            self.infoTable.reloadData()
            
            if let index = self.studentIndex,
               let vc = self.navigationController?.viewControllers[0] as? ViewController {
                vc.updateStudent(student: user, at: index)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.messageUser()
        } else if indexPath.row == 1 {
            self.callUser()
        } else if indexPath.row == 2 {
            self.emailUser()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.buttons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId.profileCollectionCell, for: indexPath) as? ProfileButtonCollectionViewCell else { fatalError("Could not create ProfileButtonCollectionViewCell") }
        
        cell.buttonLabel.text = self.buttons[indexPath.row].title
        cell.buttonImage.image =  self.buttons[indexPath.row].image
        return cell
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellId.infoTableCell) as? InfoTableViewCell else { fatalError("Could not create InfoTableViewCell") }
        
        cell.cellLabel.text = self.infoList[indexPath.row].title
        cell.cellInfoTextField.text = self.infoList[indexPath.row].info
        cell.cellInfoTextField.isUserInteractionEnabled = false // can't edit textField
        return cell
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension ProfileViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
         self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MFMessageComposeViewControllerDelegate

extension ProfileViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
