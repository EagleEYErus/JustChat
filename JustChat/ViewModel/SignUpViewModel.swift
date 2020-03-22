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
            let ref = Database.database().reference().child("users").child(uid)
            ref.updateChildValues(["name": name, "email": email]) { (err, ref) in
                if let err = err {
                    completion(.failure(err))
                }
                completion(.success(()))
            }
        }

    }
}
