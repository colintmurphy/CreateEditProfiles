//
//  ProfileViewController.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import MessageUI
import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var infoTable: UITableView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var studentImage: UIImageView!
    @IBOutlet private weak var customBackgroundView: UIView!
    @IBOutlet private weak var buttonCollectionView: UICollectionView!
    
    // MARK: - Class Variables
    
    private var infoList: [(title: String, info: String, type: ProfileButtonType)] = []
    private var buttons: [(title: String, image: UIImage, type: ProfileButtonType)] = []
    var studentIndex: (section:String, row:Int)?
    var student: Student?

    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setupUI()
        self.setupInfo()
        self.setupTable()
    }
    
    // MARK: - ACTIONS
    
    @IBAction private func edit(_ sender: Any) {
        
        let sb = UIStoryboard.init(name: StoryboardId.main, bundle: nil)
        if let vc = sb.instantiateViewController(identifier: StoryboardId.createEditVC) as? CreateEditViewController {
            
            vc.student = self.student
            vc.studentDelegate = self
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    private func callUser() {
        
        if let phone = self.student?.phone {
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
    
    private func emailUser() {
        
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
    
    private func messageUser() {
        
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
    
    // MARK: - SETUP
    
    private func setupInfo() {
        
        if let user = self.student {
            self.nameLabel.text = "\(user.firstName) \(user.lastName)"
            self.studentImage.image = user.profileImage
            self.infoList.append((title: "mobile", info: user.phone, type: .phone))
            self.infoList.append((title: "email", info: user.email, type: .email))
        }
        self.buttons.append((title: "message", image: AppImage.message, type: .message))
        self.buttons.append((title: "call", image: AppImage.call, type: .phone))
        self.buttons.append((title: "email", image: AppImage.email, type: .email))
    }
    
    private func setupTable() {
        
        self.infoTable.register(UINib(nibName: NibId.infoTableCell, bundle: nil), forCellReuseIdentifier: CellId.infoTableCell)
        self.infoTable.allowsSelection = false
        self.infoTable.isScrollEnabled = false
        self.infoTable.tableFooterView = UIView()
        self.infoTable.reloadData()
        
        self.buttonCollectionView.register(UINib(nibName: NibId.profileCollectionCell, bundle: nil), forCellWithReuseIdentifier: CellId.profileCollectionCell)
        self.buttonCollectionView.reloadData()
    }
    
    private func setupUI() {
        
        self.studentImage.layer.cornerRadius = self.studentImage.bounds.height/2
        self.studentImage.backgroundColor = .systemGray4
        self.studentImage.layer.borderWidth = 1
        self.studentImage.layer.borderColor = UIColor.systemGray.cgColor
        self.customBackgroundView.addGradient(to: self.customBackgroundView, with: [0.25, 1.0])
    }
}

// MARK: - UpdateStudentDelegate

extension ProfileViewController: UpdateStudentDelegate {
    
    func updateStudent(student: Student?, at index: (section:String, row:Int)?) {
        
        if let user = student {
            
            self.student = user
            self.nameLabel.text = "\(user.firstName) \(user.lastName)"
            self.studentImage.image = user.profileImage
            
            for (index, item) in self.infoList.enumerated() {
                if item.type == .phone {
                    self.infoList[index].info = user.phone
                } else if item.type == .email {
                    self.infoList[index].info = user.email
                }
            }
            self.infoTable.reloadData()
            
            if let index = self.studentIndex,
               let vc = self.navigationController?.viewControllers[0] as? ListViewController {
                vc.updateStudent(student: user, at: index)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? ProfileButtonCollectionViewCell
        
        switch cell?.getButtonType() {
        case .email:
            self.emailUser()
        case.phone:
            self.callUser()
        case.message:
            self.messageUser()
        case .none:
            break
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
        
        cell.set(type: self.buttons[indexPath.row].type, label: self.buttons[indexPath.row].title, image: self.buttons[indexPath.row].image)
        
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
        cell.setupProfileViewInfo(label: self.infoList[indexPath.row].title, info: self.infoList[indexPath.row].info)
        return cell
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension ProfileViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .failed:
            self.showAlert(title: "Sorry", message: "We were unable to send your email :(")
        default:
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - MFMessageComposeViewControllerDelegate

extension ProfileViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch result {
        case .failed:
            self.showAlert(title: "Sorry", message: "We were unable to send your message :(")
        default:
            self.dismiss(animated: true, completion: nil)
        }
    }
}
