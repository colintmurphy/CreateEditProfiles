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

enum ScreenSize {
    
    static let width        = UIScreen.main.bounds.size.width
    static let height       = UIScreen.main.bounds.size.height
    static let maxLength    = max(ScreenSize.width, ScreenSize.height)
    static let minLength    = min(ScreenSize.width, ScreenSize.height)
}

enum DeviceTypes {
    
    static let idiom        = UIDevice.current.userInterfaceIdiom
    static let nativeScale  = UIScreen.main.nativeScale
    static let scale        = UIScreen.main.scale

    static let isiPhoneSE               = idiom == .phone && ScreenSize.maxLength == 568.0
    static let isiPhone8Standard        = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
    static let isiPhone8Zoomed          = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale > scale /// Zoom mode on 8 = an SE
    static let isiPhone8PlusStandard    = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhone8PlusZoomed      = idiom == .phone && ScreenSize.maxLength == 736.0 && nativeScale < scale /// Zoom mode on 8+ = an 8
    static let isiPhoneX                = idiom == .phone && ScreenSize.maxLength == 812.0
    static let isiPhoneXsMaxAndXr       = idiom == .phone && ScreenSize.maxLength == 896.0
    static let isiPad                   = idiom == .pad && ScreenSize.maxLength >= 1024.0

    static func isiPhoneXAspectRatio() -> Bool {
        return isiPhoneX || isiPhoneXsMaxAndXr
    }
}
