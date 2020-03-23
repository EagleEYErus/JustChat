//
//  SignUpViewModel.swift
//  JustChat
//
//  Created by Alexander Saprykin on 23.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit.UIImage
import Firebase

final class SignUpViewModel {
    func signUp(name: String, email: String, password: String, avatarImage: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        let unknownError = NSError(domain: "Что-то пошло не так. Попробуйте еще раз.", code: -1, userInfo: nil)
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let uid = result?.user.uid else {
                completion(.failure(unknownError))
                return
            }
            
            let imageName = UUID().uuidString
            let ref = Storage.storage().reference().child("avatars").child("\(imageName).png")
            
            guard let uploadData = avatarImage.pngData() else {
                completion(.failure(unknownError))
                return
            }
            ref.putData(uploadData, metadata: nil) { (metadata, storageError) in
                if let storageError = storageError {
                    completion(.failure(storageError))
                    return
                }
                ref.downloadURL { (url, downloadUrlError) in
                    if let downloadUrlError = downloadUrlError {
                        completion(.failure(downloadUrlError))
                        return
                    }
                    guard let url = url else {
                        completion(.failure(unknownError))
                        return
                    }
                    let db = Firestore.firestore().collection("users").document(uid)
                    db.setData(["name": name, "email": email, "avatarUrl": url.absoluteString]) { err in
                        if let err = err {
                            completion(.failure(err))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
}
