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

struct AuthCredentials {
    let email: String
    let password: String
    let username: String
    let fullName: String
    let profileImage: UIImage
}

protocol RegistrationServiceProtocol {
    func register(credentials: AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void)
}

class RegistrationService: RegistrationServiceProtocol {
    func register(credentials: AuthCredentials, completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.1) else { return }
        let fileName = NSUUID().uuidString
        let storagre = STORAGE_PROFILE_IMAGES.child(fileName)
        storagre.putData(imageData, metadata: nil) { (metaData, error) in
            if let error = error {
                completion(error, DatabaseReference())
                return
            }
            storagre.downloadURL { (url, error) in
                
                guard let imageUrl = url?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
                    
                    if let error = error {
                        print("[DEBUG] error: \(error.localizedDescription)")
                        completion(error, DatabaseReference())
                        return
                    }
                    
                    guard let uid = result?.user.uid else { return }
                    
                    let values = ["email": credentials.email,
                                  "username": credentials.username,
                                  "fullName": credentials.fullName,
                                  "profileImageUrl": imageUrl]
                    
                    // save user data into realtime database.
                    REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
                }
            }
        }
    }
}
