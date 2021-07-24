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
    func login(email: String, password: String, completion: @escaping(AuthDataResult?, Error?) -> (Void))
    func login(with model: LoginModel) -> Observable<(AuthDataResult?, Error?)>
}

class LoginService: LoginServiceProtocol {
    func login(with model: LoginModel) -> Observable<(AuthDataResult?, Error?)> {
        return Observable<(AuthDataResult?, Error?)>.create { observer in
            Auth.auth().signIn(withEmail: model.email, password: model.password) { result, error in
                observer.onNext((result, error))
            }
            return Disposables.create()
        }
    }
    
    func login(email: String, password: String, completion: @escaping(AuthDataResult?, Error?) -> (Void)) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
}
