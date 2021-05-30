//
//  UITextFieldExtension.swift
//  Triponus
//
//  Created by Be More on 27/05/2021.
//

import UIKit

extension UITextField {
    @IBInspectable var placeholderAttributed: String? {
        get {
            return self.placeholder
        } set {
            let placeholder = NSAttributedString(string: newValue ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "E4E4E4") ?? .lightGray])
            self.attributedPlaceholder = placeholder
        }
    }
}
