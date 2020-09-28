//
//  Contact.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/18/20.
//

import UIKit

struct Student: Decodable {
    
    var firstName: String
    var lastName: String
    var phone: String
    var email: String
    var profileImage: UIImage?
    
    enum CodingKeys: String, CodingKey {
        
        case firstName
        case lastName
        case phone
        case email
    }
    
    mutating func update(withImage image: UIImage) {
        self.profileImage = image
    }
}
