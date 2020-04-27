//
//  ChatListViewModel.swift
//  JustChat
//
//  Created by Alexander Saprykin on 27.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Firebase

final class ChatListViewModel {
    
    var chats: [ChatPreview] = []
    
    var numberOfRows: Int {
        return chats.count
    }
    
    private var listener: ListenerRegistration?
    
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
            var recipientIds = [String]()
            var lastMessages = [String: [String: Any]]()
            for document in documents {
                guard let userIds = document.data()["users"] as? [String] else { continue }
                guard let recipientId = userIds.filter({ $0 != userId }).first else { continue }
                recipientIds.append(recipientId)
                guard let lastMessage = document.data()["lastMessage"] as? String,
                    let lastMessageTimestamp = document.data()["lastMessageTimestamp"] as? Timestamp else { continue }
                lastMessages[recipientId] = [
                    "text": lastMessage,
                    "timestamp": lastMessageTimestamp
                ]
            }
            if recipientIds.count == 0 {
                completion(.success(()))
                return
            }
            Firestore.firestore().collection("users").whereField("id", in: recipientIds).getDocuments { (userSnap, userError) in
                if let userError = userError {
                    completion(.failure(userError))
                    return
                }
                guard let userDocuments = userSnap?.documents else {
                    completion(.failure(unknownError))
                    return
                }
                var chats = [ChatPreview]()
                for document in userDocuments {
                    guard let user = User(dictionary: document.data()) else {
                        completion(.failure(unknownError))
                        return
                    }
                    var lastMessage: String?
                    var lastMessageTimestamp: Timestamp?
                    if let message = lastMessages[user.id]?["text"] as? String,
                        let created = lastMessages[user.id]?["timestamp"] as? Timestamp {
                        lastMessage = message
                        lastMessageTimestamp = created
                    }
                    chats.append(.init(user: user, lastMessage: lastMessage, lastMessageTimestamp: lastMessageTimestamp))
                }
                self?.chats = chats
                completion(.success(()))
            }
        }
    }
    
    func observeChats(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        removeListener()
        listener = Firestore.firestore().collectionGroup("thread").addSnapshotListener { [weak self] (_, _) in
            self?.fetchChats(userId: userId, completion: completion)
        }
    }
    
    private func removeListener() {
        listener?.remove()
    }
    
    deinit {
        removeListener()
    }
}
