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
}
