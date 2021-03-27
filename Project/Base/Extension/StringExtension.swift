//
//  StringExtension.swift
//  Project
//
//  Created by Be More on 22/03/2021.
//

import Foundation

extension String {
    /// Check if a string nil or empty
    /// - Parameters:
    ///   - aString: input string
    /// - Returns: Bool
    static func isNilOrEmpty(_ aString: String?) -> Bool {
        return !(aString != nil && "\(aString ?? "")".count != 0)
    }
    
    /// Validate email
    /// - Returns: Void
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
