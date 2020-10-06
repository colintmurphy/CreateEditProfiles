//
//  UpdateUserDelegate.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/19/20.
//

import Foundation

protocol UpdateStudentDelegate: AnyObject {
    func updateStudent(student: Student?, at index: (section: String, row: Int)?)
}
