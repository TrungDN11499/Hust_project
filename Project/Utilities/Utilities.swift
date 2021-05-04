//
//  Utilities.swift
//  Project
//
//  Created by Be More on 9/29/20.
//

import UIKit

class Utilities {
    func inputContainerView(image: UIImage, textField: UITextField) -> UIView {
        
        let view = UIView()
        
        let iconImage = UIImageView()
        iconImage.image = image.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = .black
        view.addSubview(iconImage)
        iconImage.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, paddingLeft: 8, paddingBottom: 8, width: 24, height: 24)
        
        view.addSubview(textField)
        textField.anchor(left: iconImage.rightAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor,
                         paddingLeft: 8,
                         paddingBottom: 8,
                         paddingRight: 8)
        
        let dividerView = UIView()
        dividerView.backgroundColor = .darkGray
        view.addSubview(dividerView)
        dividerView.anchor(left: iconImage.leftAnchor, bottom: view.bottomAnchor, right: textField.rightAnchor, height: 0.75)
        
        return view
        
    }
    
    func textField(withPlaceholder placeholder: String) -> BindingTextField {
        
        let textField = BindingTextField(controlEvent: .editingChanged)
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        return textField
        
    }
    
    func attributeButton(_ firstPart: String, _ secondPart: String) -> BindingButton {
        
        let button = BindingButton(controlEvent: .touchUpInside)
        
        let attributedTitle = NSMutableAttributedString(string: firstPart, attributes: [NSMutableAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSMutableAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        attributedTitle.append(NSMutableAttributedString(string: secondPart, attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSMutableAttributedString.Key.foregroundColor: UIColor.twitterBlue]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
        
    }
}
