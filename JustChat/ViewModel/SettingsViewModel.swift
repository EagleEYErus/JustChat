//
//  SettingsViewModel.swift
//  JustChat
//
//  Created by Alexander Saprykin on 20.04.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Firebase

final class SettingsViewModel {
    func updateUsername(by user: Firebase.User, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let unknownError = NSError(domain: "Что-то пошло не так. Попробуйте еще раз.", code: -1, userInfo: nil)
        Firestore.firestore().collection("users").whereField("id", isEqualTo: user.uid).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let document = snapshot?.documents.first else {
                completion(.failure(unknownError))
                return
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges()

            document.reference.updateData(["name": username]) { (updateError) in
                if let err = updateError {
                    completion(.failure(err))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func updateAvatar(by user: Firebase.User, image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        let unknownError = NSError(domain: "Что-то пошло не так. Попробуйте еще раз.", code: -1, userInfo: nil)
        Firestore.firestore().collection("users").whereField("id", isEqualTo: user.uid).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let document = snapshot?.documents.first else {
                completion(.failure(unknownError))
                return
            }
            guard let userDocument = User(dictionary: document.data()) else {
                completion(.failure(unknownError))
                return
            }
            guard let urlEnd = userDocument.avatarUrl.components(separatedBy: "/").last,
                let oldImageName = urlEnd.components(separatedBy: "?").first?.components(separatedBy: "%2F").last else {
                    completion(.failure(unknownError))
                    return
            }
            Storage.storage().reference().child("avatars").child(oldImageName).delete { (storageError) in
                if let error = storageError {
                    print(error.localizedDescription)
                }
            }
            let imageName = UUID().uuidString
            let ref = Storage.storage().reference().child("avatars").child("\(imageName).jpg")
            
            guard let uploadData = image.jpegData(compressionQuality: 0.1) else {
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
                    changeRequest.photoURL = url
                    changeRequest.commitChanges()
                    user.reload(completion: nil)
                    
                    document.reference.updateData(["avatarUrl": url.absoluteString]) { (updateError) in
                        if let err = updateError {
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
