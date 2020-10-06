//
//  InfoTableViewCellDelegate.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/22/20.
//

import UIKit

protocol InfoTableViewCellDelegate: AnyObject {
    func didChangeInTextField(_ textField: CustomTextField)
}
