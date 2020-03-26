//
//  ContactListViewModel.swift
//  JustChat
//
//  Created by Alexander Saprykin on 23.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Firebase

final class ContactListViewModel {
    
    var users: [User] = []
    
    var numberOfRows: Int {
        return users.count
    }
    
    func fetchContacts(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Firestore.firestore().collection("users").order(by: "name").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.failure(NSError(domain: "Ошибка загрузки", code: -1, userInfo: nil)))
                return
            }
            self?.users = documents.compactMap { User(dictionary: $0.data()) }
                .filter { $0.email != email }
            completion(.success(()))
        }
    }
}
