//
//  ViewController.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class ListViewController: UIViewController {
    
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
        self.loadDataFromPlist()
        
        // MARK: Setting a Background image for TableView
        /*
        let backgroundImage = AppImage.defaultImage
        let imageView = UIImageView(image: _INSERT-STUDENT-IMAGE_)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemTeal
        studentTable.backgroundView = imageView
        studentTable.tableFooterView = UIView()
         */
    }

    // MARK: - Actions
    
    @IBAction private func addContact(_ sender: Any) {
        
        let sb = UIStoryboard.init(name: StoryboardId.main, bundle: nil)
        if let vc = sb.instantiateViewController(identifier: StoryboardId.createEditVC) as? CreateEditViewController {
            
            vc.studentDelegate = self
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    private func insert(char: String, user: Student) {
        
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
    
    // MARK: - Configure
    
    private func loadDataFromPlist() {
        
        guard var studentList: [Student] = self.getPlist(withName: "Students") else { return }
        
        for (index, student) in studentList.enumerated() {
            
            studentList[index].update(withImage: AppImage.defaultImage)
            if let char = student.firstName.first {
                self.insert(char: String(char), user: studentList[index])
            }
        }
    }
    
    private func getPlist<T: Decodable>(withName name: String) -> T? {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "plist"),
            let data = FileManager.default.contents(atPath: path) else { return nil }
        do {
            /// with PropertyListSerialization
            /*  let dataFromList = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil)
                return dataFromList as? [[String: Any]] */
            
            /// with PropertyListDecoder
            let obj = try PropertyListDecoder().decode(T.self, from: data)
            return obj
        } catch let error {
            print(error)
        }
        return nil
    }
}

// MARK: - UpdateUserProtocol

extension ListViewController: UpdateStudentDelegate {
    
    func updateStudent(student: Student?, at index: (section: String, row: Int)?) {
        
        if let user = student,
           let char = user.firstName.first?.uppercased() {
            
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

extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ListViewController: UITableViewDataSource {
    
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
            }
        }
        return cell
    }
}
