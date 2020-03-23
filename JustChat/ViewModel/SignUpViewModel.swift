//
//  SignUpViewModel.swift
//  JustChat
//
//  Created by Alexander Saprykin on 23.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Firebase

final class SignUpViewModel {
    func signUp(name: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let uid = result?.user.uid else { return }
            let db = Firestore.firestore().collection("users").document(uid)
            db.setData(["name": name, "email": email]) { err in
                if let err = err {
                    completion(.failure(err))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
