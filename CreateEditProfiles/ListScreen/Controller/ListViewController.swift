//
//  ViewController.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

class ListViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var studentTable: UITableView!
    @IBOutlet private weak var emptyListLabel: UILabel!
    
    // MARK: - Class Variables
    
    private var sections: [String] = []
    private var studentList: [String: [(contact: Student, isFavorite: Bool)]] = [:] {
        didSet {
            if !studentList.isEmpty {
                self.emptyListLabel.isHidden = true
                self.studentTable.isHidden = false
                self.studentTable.reloadData()
            } else {
                self.emptyListLabel.isHidden = false
                self.studentTable.isHidden = true
            }
        }
    }
    
    private var xmlElementName = ""
    private var xmlFirstName = ""
    private var xmlLastName = ""
    private var xmlEmail = ""
    private var xmlPhone = ""
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.studentTable.isHidden = true
        self.loadDataFromPlist()
        self.loadDataFromTextFile()
        self.loadDataFromJSONFile()
        self.loadDataFromXMLFile(withName: "Students")
        
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
        
        let story = UIStoryboard(name: StoryboardId.main, bundle: nil)
        if let createEditVC = story.instantiateViewController(withIdentifier: StoryboardId.createEditVC) as? CreateEditViewController {
            
            createEditVC.studentDelegate = self
            let nav = UINavigationController(rootViewController: createEditVC)
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    private func insert(char: String, user: Student) {
        
        if var contactsForSection = self.studentList[char] {
            if !contactsForSection.isEmpty {
                // hits if remove last student from section, then add new student to same section
                self.sections.append(char)
                self.sections.sort()
            }
            
            // add student to existing section
            contactsForSection.append((contact: user, isFavorite: false))
            contactsForSection.sort {
                ($0.contact.firstName + $0.contact.lastName) < ($1.contact.firstName + $1.contact.lastName)
            }
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
    
    // MARK: - Load from File
    
    private func loadDataFromPlist() {
        
        guard var studentList: [Student] = self.getPlistFile(withName: "Students") else { return }
        for (index, student) in studentList.enumerated() {
            if let char = student.firstName.first {
                studentList[index].update(withImage: AppImage.defaultImage)
                self.insert(char: String(char), user: studentList[index])
            }
        }
    }
    
    private func loadDataFromTextFile() {
        
        guard let studentList: String = self.getTextFile(withName: "Students") else { return }
        self.parseTextFileResults(of: studentList)
    }
    
    private func loadDataFromJSONFile() {
        
        guard var studentList: [Student] = self.getJSONFile(withName: "Students") else { return }
        for (index, student) in studentList.enumerated() {
            if let char = student.firstName.first {
                studentList[index].update(withImage: AppImage.defaultImage)
                self.insert(char: String(char), user: studentList[index])
            }
        }
    }
    
    private func loadDataFromXMLFile(withName name: String) {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "xml") else { return }
        if let parser = XMLParser(contentsOf: URL(fileURLWithPath: path)) {
            parser.delegate = self
            parser.parse()
        }
    }
    
    // MARK: - Read File
    
    private func getPlistFile<T: Decodable>(withName name: String) -> T? {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "plist"),
            let data = FileManager.default.contents(atPath: path) else { return nil }
        do {
            let obj = try PropertyListDecoder().decode(T.self, from: data)
            return obj
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func getTextFile(withName name: String) -> String? {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "txt") else { return nil }
        do {
            let dataContent = try String(contentsOfFile: path, encoding: .utf8)
            return dataContent
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func getJSONFile<T: Decodable>(withName name: String) -> T? {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "json") else { return nil }
        do {
            let data = try NSData(contentsOfFile: path, options: .mappedIfSafe) as Data
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch let error {
            print(error)
        }
        return nil
    }
    
    // MARK: - Parsers
    
    private func parseTextFileResults(of array: String) {
        
        let tempArr = array.components(separatedBy: ",")
        
        var arrayOfStrings = [String]()
        tempArr.forEach { string in
            arrayOfStrings.append(string.self.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        for student in arrayOfStrings {
            let studentArr = student.components(separatedBy: " ")
            if studentArr.count == 4 {
                
                var newStudent = Student(firstName: studentArr[0], lastName: studentArr[1], phone: studentArr[3], email: studentArr[2])
                newStudent.update(withImage: AppImage.defaultImage)
                if let char = studentArr[0].first {
                    self.insert(char: String(char), user: newStudent)
                }
            }
        }
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
                    self.studentList[char]?.sort {
                        ($0.contact.firstName + $0.contact.lastName) < ($1.contact.firstName + $1.contact.lastName)
                    }
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
        
        if !self.sections.isEmpty {
            let key = self.sections[section]
            if let count = self.studentList[key]?.count {
                return count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellId.userTableCell) as? UserTableViewCell else { fatalError("Could not create UserTableViewCell") }
        
        if !self.sections.isEmpty {
            let key = self.sections[indexPath.section]
            
            if let user = self.studentList[key]?[indexPath.row],
               let image = user.contact.profileImage {
                
                let name = "\(user.contact.firstName) \(user.contact.lastName)"
                cell.set(name: name, image: image)
            }
        }
        return cell
    }
}

// MARK: - XMLParserDelegate

extension ListViewController: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        
        if elementName == "student" {
            self.xmlEmail = ""
            self.xmlFirstName = ""
            self.xmlLastName = ""
            self.xmlPhone = ""
        }
        self.xmlElementName = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
       if elementName == "student" {
           var student = Student(firstName: self.xmlFirstName, lastName: self.xmlLastName, phone: self.xmlPhone, email: self.xmlEmail)
           student.update(withImage: AppImage.defaultImage)
           if let char = self.xmlFirstName.first {
               self.insert(char: String(char), user: student)
           }
       }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if self.xmlElementName == "email" {
            self.xmlEmail += data
        } else if self.xmlElementName == "firstName" {
            self.xmlFirstName += data
        } else if self.xmlElementName == "lastName" {
            self.xmlLastName += data
        } else if self.xmlElementName == "phone" {
            self.xmlPhone += data
        }
    }
}
