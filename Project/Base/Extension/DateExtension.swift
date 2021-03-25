//
//  DateExtension.swift
//  Project
//
//  Created by Be More on 24/03/2021.
//

import Foundation

extension Date {
    func stringForLog() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        return df.string(from: self)
    }
}
