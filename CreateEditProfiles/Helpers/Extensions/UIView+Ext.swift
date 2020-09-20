//
//  UIView+Ext.swift
//  CreateEditProfiles
//
//  Created by Colin Murphy on 9/19/20.
//

import UIKit

extension UIView {
    
    func addGradient(to view: UIView, with range: [NSNumber]) {
        
        let colorTop =  UIColor.clear.cgColor
        let colorBottom = AppColor.primaryColor.cgColor
        
        let gradientBackground = CAGradientLayer()
        gradientBackground.colors = [colorTop, colorBottom]
        gradientBackground.locations = range
        gradientBackground.frame = view.bounds
        view.layer.insertSublayer(gradientBackground, at: 0)
    }
}
