//
//  LoginViewModel.swift
//  Project
//
//  Created by Be More on 10/11/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class LoginViewModel: ViewModelProtocol {
    
    struct Input {
        let email: Observable<String> = Observable()
        let password: Observable<String> = Observable()
        let signInDidTap: Observable<Any> = Observable()
    }

    struct Output {
        let errorsObservable: Observable<String> = Observable()
        let successObservable: Observable<Bool> = Observable()
    }
        
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    init(loginService: LoginServiceProtocol) {
        self.input = Input()
        self.output = Output()
        
        self.input.signInDidTap.bind {[unowned self] observer, value in
            guard let email = self.input.email.value, !String.isNilOrEmpty(email) else {
                self.output.errorsObservable.value = "Email cannot left empty"
                return
            }
            
            guard let password = self.input.password.value, !String.isNilOrEmpty(password) else {
                self.output.errorsObservable.value = "Password cannot left empty"
                return
            }
            
            loginService.login(email: email, password: password) { (result, error) in
                if let error = error {
                    self.output.errorsObservable.value = error.localizedDescription
                    return
                }
                self.output.successObservable.value = true
            }
            
        }
    }
}
