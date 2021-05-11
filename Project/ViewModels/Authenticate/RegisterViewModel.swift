//
//  RegisterViewModel.swift
//  Project
//
//  Created by Be More on 10/11/20.
//

import UIKit

class RegisterViewModel: ViewModelProtocol {
        
    struct Input {
        let email: Observable<String> = Observable()
        let password: Observable<String> = Observable()
        let confirmPassword: Observable<String> = Observable()
        let fullName: Observable<String> = Observable()
        let userName: Observable<String> = Observable()
        let profileImage: Observable<UIImage> = Observable()
        let registerDidTap: Observable<Any> = Observable()
    }
    
    struct Output {
        let errorsObservable: Observable<String> = Observable()
        let successObservable: Observable<Bool> = Observable()
    }
    
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    init(registrationService: RegistrationService) {
        self.input = Input()
        self.output = Output()
        
        self.input.registerDidTap.bind {[unowned self] observer, value in
            guard let email = self.input.email.value, !String.isNilOrEmpty(email) else {
                self.output.errorsObservable.value = "Email is empty"
                return
            }
            
            guard let password = self.input.password.value, !String.isNilOrEmpty(password) else {
                self.output.errorsObservable.value = "Password is empty"
                return
            }
            guard let comfirmPassword = self.input.confirmPassword.value, !String.isNilOrEmpty(comfirmPassword) else {
                self.output.errorsObservable.value = "Please comfirm your password"
                return
            }
            guard let fullName = self.input.fullName.value, !String.isNilOrEmpty(fullName) else {
                self.output.errorsObservable.value = "FullName is empty"
                return
            }
            
            guard let userName = self.input.userName.value, !String.isNilOrEmpty(userName) else {
                self.output.errorsObservable.value = "UserName is empty"
                return
            }
            if password != comfirmPassword {
                self.output.errorsObservable.value = "Password is not matching, Please try again"
                return
            }
            let avatar = self.input.profileImage.value ?? UIImage(named: "ic_default_user")
            registrationService.register(credentials: AuthCredentials(email: email, password: password, username: userName, fullName: fullName, profileImage: avatar!)) { error, value in
                if let error = error {
                    self.output.errorsObservable.value = error.localizedDescription
                    return
                }
                self.output.successObservable.value = true
            }
            
        }
    }
}
