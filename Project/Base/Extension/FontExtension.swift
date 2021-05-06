//
//  FontExtension.swift
//  Triponus
//
//  Created by Be More on 06/05/2021.
//

import UIKit

extension UIFont {
    static let robotoRegularName = "Roboto-Regular"
    static let robotoMediumName = "Roboto-Medium"
    static let robotoBoldName = "Roboto-Bold"
}

extension UIFont {
    /// Show all available fonts in project
    /// - Returns: Void
    static func showAllAvailableFonts() {
        for family in UIFont.familyNames {
            
            let sName: String = family as String
            dLogInfo("Family name: \(sName)")
            
            for name in UIFont.fontNames(forFamilyName: sName) {
                dLogInfo("Font name: \(name as String)")
            }
        }
    }
    
    /// Roboto regular
    /// - Parameters:
    ///   - point: font size
    /// - Returns: UIFont
    static func robotoRegular(point: CGFloat) -> UIFont {
        if let roboto = UIFont(name: UIFont.robotoRegularName,
                               size: point) {
            return roboto
        }
        return UIFont.systemFont(ofSize: point)
    }
    
    /// Roboto semibold
    /// - Parameters:
    ///   - point: font size
    /// - Returns: UIFont
    static func robotoMedium(point: CGFloat) -> UIFont {
        if let roboto = UIFont(name: UIFont.robotoMediumName,
                               size: point) {
            return roboto
        }
        return UIFont.systemFont(ofSize: point)
    }
    
    /// Roboto bold
    /// - Parameters:
    ///   - point: font size
    /// - Returns: UIFont
    static func robotoBold(point: CGFloat) -> UIFont {
        if let roboto = UIFont(name: UIFont.robotoBoldName,
                               size: point) {
            return roboto
        }
        return UIFont.systemFont(ofSize: point)
    }
    
}


