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
            guard let user = result?.user else {
                completion(.failure(unknownError))
                return
            }
            
            let imageName = UUID().uuidString
            let ref = Storage.storage().reference().child("avatars").child("\(imageName).jpg")
            
            guard let uploadData = avatarImage.jpegData(compressionQuality: 0.1) else {
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
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = name
                    changeRequest.photoURL = url
                    changeRequest.commitChanges()
                    user.reload(completion: nil)

                    let db = Firestore.firestore().collection("users").document(user.uid)
                    db.setData(["id": user.uid, "name": name, "email": email, "avatarUrl": url.absoluteString]) { err in
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
