//
//  Constants.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/19/20.
//

import UIKit

enum AppColor {
    static let primaryColor             = UIColor.systemTeal
}

enum AppImage {
    static let defaultImage: UIImage!   = UIImage(named: "icons8-user")
    static let email: UIImage!          = UIImage(named: "icons8-secured_letter")
    static let message: UIImage!        = UIImage(named: "icons8-speech")
    static let call: UIImage!           = UIImage(named: "icons8-phone")
}

enum CellId {
    static let infoTableCell            = "InfoTableViewCell"
    static let profileCollectionCell    = "ProfileButtonCollectionViewCell"
    static let userTableCell            = "UserTableViewCell"
}

enum NibId {
    static let infoTableCell            = "InfoTableViewCell"
    static let profileCollectionCell    = "ProfileButton"
}

enum StoryboardId {
    static let main                     = "Main"
    static let createEditVC             = "CreateEditViewController"
}

enum SegueId {
    static let toProfile                = "toProfile"
}
