//
//  ChatListViewModel.swift
//  JustChat
//
//  Created by Alexander Saprykin on 27.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Firebase

final class ChatListViewModel {
    
    var chats: [Chat] = []
    
    var numberOfRows: Int {
        return chats.count
    }
        
    private func fetchChats(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let unknownError = NSError(domain: "Ошибка загрузки данных. Попробуйте позже.", code: -1, userInfo: nil)
        Firestore.firestore().collection("chats").whereField("users", arrayContains: userId).getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.failure(unknownError))
                return
            }
            var chats = [Chat]()
            let dispatchGroup = DispatchGroup()
            var err: Error?
            for document in documents {
                guard let userIds = document.data()["users"] as? [String] else { return }
                guard let recipientId = userIds.filter({ $0 != userId }).first else { return }
                dispatchGroup.enter()
                Firestore.firestore().collection("users").whereField("id", isEqualTo: recipientId).addSnapshotListener { (userSnap, userError) in
                    if let userError = userError {
                        err = userError
                        return
                    }
                    guard let user = userSnap?.documents.compactMap({ User(dictionary: $0.data()) }).first else {
                        return
                    }
                    document.reference.collection("thread").order(by: "created").limit(toLast: 1).getDocuments { (messSnap, messError) in
                        if let messError = messError {
                            err = messError
                            return
                        }
                        guard let doc = messSnap?.documents.first else {
                            chats.append(.init(user: user, lastMessage: nil))
                            dispatchGroup.leave()
                            return
                        }
                        let message = Message(dictionary: doc.data())
                        chats.append(.init(user: user, lastMessage: message))
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    guard err == nil else  {
                        completion(.failure(unknownError))
                        return
                    }
                    self?.chats = chats
                    completion(.success(()))
                }
            }
        }
    }
    
    func observeChats(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Firestore.firestore().collectionGroup("thread").addSnapshotListener { [weak self] (_, _) in
            self?.fetchChats(userId: userId, completion: completion)
        }
    }
}
