//
//  UpdateUserDelegate.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/19/20.
//

import Foundation

protocol UpdateStudentDelegate: class {
    func updateStudent(student: Student?, at index: (section:String, row:Int)?)
}
