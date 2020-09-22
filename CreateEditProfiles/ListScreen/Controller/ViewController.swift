//
//  ViewController.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var studentTable: UITableView!
    @IBOutlet weak var emptyListLabel: UILabel!
    
    // MARK: - Class Variables
    
    var sections: [String] = []
    var studentList: [String: [(contact: Student, isFavorite: Bool)]] = [:] {
        didSet {
            if studentList.count > 0 {
                self.emptyListLabel.isHidden = true
                self.studentTable.isHidden = false
                self.studentTable.reloadData()
            } else {
                self.emptyListLabel.isHidden = false
                self.studentTable.isHidden = true
            }
        }
    }
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.studentTable.isHidden = true
    }

    // MARK: - Actions
    
    @IBAction func addContactBarButton(_ sender: Any) {
        let sb = UIStoryboard.init(name: StoryboardId.main, bundle: nil)
        if let vc = sb.instantiateViewController(identifier: StoryboardId.createEditVC) as? CreateEditViewController {
            vc.studentDelegate = self
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueId.toProfile {
            if let detailVC = segue.destination as? ProfileViewController {
                if let index = studentTable.indexPathForSelectedRow {
                    let key = self.sections[index.section]
                    let user = self.studentList[key]?[index.row].contact
                    detailVC.student = user
                    detailVC.studentIndex = (section: key, row: index.row)
                }
            }
        }
    }
}

// MARK: - UpdateUserProtocol

extension ViewController: UpdateStudentDelegate {
    
    func updateStudent(student: Student?, at index: (section:String, row:Int)?) {
        
        if let user = student,
           let char = user.firstName.first?.uppercased() {
                
            func insert(char: String, user: Student) {
                if var contactsForSection = self.studentList[char] {
                    
                    if contactsForSection.count == 0 {
                        // hits if remove last student from section, then add new student to same section
                        self.sections.append(char)
                        self.sections.sort()
                    }
                    
                    // add student to existing section
                    contactsForSection.append((contact: user, isFavorite: false))
                    contactsForSection.sort(by: { "\($0.contact.firstName) \($0.contact.lastName)" < "\($1.contact.firstName) \($1.contact.lastName)" })
                    self.studentList[char] = contactsForSection
                } else {
                    // first student to enter section
                    self.sections.append(char)
                    self.sections.sort()
                    self.studentList[char] = [(contact: user, isFavorite: false)]
                }
            }
            
            if let index = index {
                // Edited student
                if index.section == char {
                    // IF the student's first name did not change
                    self.studentList[char]?[index.row].contact = user
                    self.studentList[char]?.sort(by: { "\($0.contact.firstName) \($0.contact.lastName)" < "\($1.contact.firstName) \($1.contact.lastName)" })
                } else {
                    // student's first name DID change
                    insert(char: char, user: user)
                    if self.studentList[index.section]?.count == 1 {
                        self.sections.remove(at: 0)
                    }
                    self.studentList[index.section]?.remove(at: index.row)
                }
            } else {
                // New student
                insert(char: char, user: user)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sections.count > 0 {
            let key = self.sections[section]
            if let count = self.studentList[key]?.count {
                return count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellId.userTableCell) as? UserTableViewCell else { fatalError("Could not create UserTableViewCell") }
        
        if self.sections.count > 0 {
            let key = self.sections[indexPath.section]
            
            if let user = self.studentList[key]?[indexPath.row] {
                cell.studentNameLabel.text = "\(user.contact.firstName) \(user.contact.lastName)"
                cell.profileImageView.image = user.contact.profileImage
                if user.isFavorite {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
        }
        return cell
    }
}
