//
//  LoginService.swift
//  Project
//
//  Created by Be More on 10/11/20.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import RxSwift

protocol LoginServiceProtocol {
    func login(with model: LoginModel) -> Observable<(AuthDataResult?, Error?)>
}

class LoginService: LoginServiceProtocol {
    func login(with model: LoginModel) -> Observable<(AuthDataResult?, Error?)> {
        return Observable<(AuthDataResult?, Error?)>.create { observer in
            if String.isNilOrEmpty(model.email) {
                let error = TriponusAuthencationError.emptyEmail
                observer.onNext((nil, error))
                return Disposables.create()
            } else {
                if !model.email.isValidEmail() {
                    let error = TriponusAuthencationError.emailValidationError
                    observer.onNext((nil, error))
                    return Disposables.create()
                }
            }
            if String.isNilOrEmpty(model.password) {
                observer.onNext((nil, TriponusAuthencationError.passwordEmpty))
                return Disposables.create()
            }
            Auth.auth().signIn(withEmail: model.email, password: model.password) { result, error in
                observer.onNext((result, error))
            }
            return Disposables.create()
        }
    }
}
