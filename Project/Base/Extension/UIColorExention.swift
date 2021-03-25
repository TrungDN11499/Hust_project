//
//  UIColorExention.swift
//  Project
//
//  Created by Be More on 11/1/20.
//

import UIKit

extension UIColor {
    
    /// Sort way to create a color with R G B input
    /// - Parameters:
    ///   - red: red color
    ///   - green: green color
    ///   - blue: blue color
    /// - Returns: UIColor
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
}
