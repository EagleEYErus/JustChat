//
//  MessageListViewModel.swift
//  JustChat
//
//  Created by Alexander Saprykin on 26.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Firebase

final class MessageListViewModel {
    
    var messages: [Message] = []
    
    var messagesCount: Int {
        return messages.count
    }
    
    private var userIds: [String]
    private var listener: ListenerRegistration?
    private var searchArray: [[String]]
    private let unknownError = NSError(domain: "Что-то пошло не так. Попробуйте еще раз.", code: -1, userInfo: nil)
    
    init(userIds: [String]) {
        self.userIds = userIds
        self.searchArray = [userIds, [userIds[1], userIds[0]]]
    }
    
    func sendMessage(message: Message, completion: @escaping (Result<Void, Error>) -> Void) {
        Firestore.firestore().collection("chats").whereField("users", in: searchArray).getDocuments { [weak self] (snapshot, chatsError) in
            guard let strongSelf = self else { return }
            guard let documents = snapshot?.documents else {
                completion(.failure(strongSelf.unknownError))
                return
            }
            if documents.count == 0 {
                strongSelf.createChatIfNot { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    strongSelf.sendMessage(message: message, completion: completion)
                }
                return
            }
            guard let doc = documents.first else {
                completion(.failure(strongSelf.unknownError))
                return
            }
            doc.reference.collection("thread").addDocument(data: message.dictionary) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func observeMessages(completion: @escaping (Result<Void, Error>) -> Void) {
        Firestore.firestore().collection("chats").whereField("users", in: searchArray).getDocuments { [weak self] (snapshot, error) in
            guard let strongSelf = self else { return }
            guard let documents = snapshot?.documents else {
                completion(.failure(strongSelf.unknownError))
                return
            }
            if documents.count == 0 {
                strongSelf.createChatIfNot { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    strongSelf.observeMessages(completion: completion)
                }
                return
            }
            guard let doc = documents.first else {
                completion(.failure(strongSelf.unknownError))
                return
            }
            strongSelf.listener = doc.reference.collection("thread").order(by: "created").addSnapshotListener { (messagesSnaphot, messagesError) in
                if let err = messagesError {
                    completion(.failure(err))
                    return
                }
                guard let document = messagesSnaphot?.documents else {
                    completion(.failure(strongSelf.unknownError))
                    return
                }
                strongSelf.messages = document.compactMap { Message(dictionary: $0.data()) }
                completion(.success(()))
            }
        }
    }
    
    private func createChatIfNot(completion: @escaping (Error?) -> Void) {
        Firestore.firestore().collection("chats").whereField("users", in: searchArray).getDocuments { [weak self] (snapshot, chatsError) in
            guard let strongSelf = self else { return }
            if let error = chatsError {
                completion(error)
                return
            }
            guard let documents = snapshot?.documents else { return }
            if documents.count == 0 {
                Firestore.firestore().collection("chats").addDocument(data: ["users": strongSelf.userIds]) { error in
                    completion(error)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
