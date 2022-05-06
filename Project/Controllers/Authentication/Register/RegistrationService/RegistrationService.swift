//
//  RegistrationService.swift
//  Project
//
//  Created by Be More on 25/03/2021.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import RxSwift

protocol RegistrationServiceProtocol {
    func register(with model: RegisterModel, uploadProgress: @escaping(Double) -> Void) -> Observable<(DatabaseReference?, Error?)>
}

class RegistrationService: RegistrationServiceProtocol {
    func register(with model: RegisterModel, uploadProgress: @escaping(Double) -> Void) -> Observable<(DatabaseReference?, Error?)> {
        guard let imageData = model.profileImage.jpegData(compressionQuality: 0.1) else {
            return Observable<(DatabaseReference?, Error?)>.create { _ in
                return Disposables.create()
            }
        }
        let fileName = NSUUID().uuidString
        let storagre = STORAGE_PROFILE_IMAGES.child(fileName)
        
        return Observable<(DatabaseReference?, Error?)>.create { observer in
            
            // check email empty
            if String.isNilOrEmpty(model.email) {
                let error = TriponusAuthencationError.emptyEmail
                observer.onNext((nil, error))
                return Disposables.create()
            }
            
            // Email validation
            if !model.email.isValidEmail() {
                let error = TriponusAuthencationError.emailValidationError
                observer.onNext((nil, error))
                return Disposables.create()
            }
            
            // check password match
            if model.password != model.confirmPassword {
                let error = TriponusAuthencationError.passwordNotMatch
                observer.onNext((nil, error))
                return Disposables.create()
            }
            
            let upload = storagre.putData(imageData)
            // catch upload progress block.
            upload.observe(.progress) { snapshot in
                let percentComplete = (Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)) * 100.0
                // upload progress
                uploadProgress(percentComplete)
            }
            
            // upload success
            upload.observe(.success) { _ in
                storagre.downloadURL { (url, error) in
                    
                    guard let imageUrl = url?.absoluteString else { return }
                    
                    Auth.auth().createUser(withEmail: model.email, password: model.password) { (result, error) in
                        
                        if let error = error {
                            dLogError(error.localizedDescription)
                            storagre.delete(completion: nil)
                            observer.onNext((nil, error))
                        }
                        
                        guard let uid = result?.user.uid else { return }
                        
                        let values = ["email": model.email,
                                      "username": model.username,
                                      "fullName": model.fullName,
                                      "profileImageUrl": imageUrl]
                        
                        // save user data into realtime database.
                        REF_USERS.child(uid).updateChildValues(values) { error, result in
                            observer.onNext((result, error))
                        }
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}
