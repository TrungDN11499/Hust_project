//
//  RegisterModel.swift
//  Triponus
//
//  Created by Be More on 24/07/2021.
//

import UIKit

class RegisterModel {
    var email: String
    var password: String
    var confirmPassword: String
    var username: String
    var fullName: String
    var profileImage: UIImage
    
    init(email: String, password: String, confirmPassword: String, username: String, fullName: String, profileImage: UIImage) {
        self.email = email
        self.password = password
        self.confirmPassword = confirmPassword
        self.username = username
        self.fullName = fullName
        self.profileImage = profileImage
    }
}
