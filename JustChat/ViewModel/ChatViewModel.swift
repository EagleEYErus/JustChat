//
//  ChatViewModel.swift
//  JustChat
//
//  Created by Alexander Saprykin on 26.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Firebase

final class ChatViewModel {
    
    var messages: [Message] = []
    
    var messagesCount: Int {
        return messages.count
    }
    
    private var userIds: [String]
    private var messagesListener: ListenerRegistration?
    private var isTypingListener: ListenerRegistration?
    private let unknownError = NSError(domain: "Что-то пошло не так. Попробуйте еще раз.", code: -1, userInfo: nil)
    
    init(userIds: [String]) {
        self.userIds = userIds
    }
    
    func sendMessage(message: Message, completion: @escaping (Result<Void, Error>) -> Void) {
        Firestore.firestore().collection("chats").whereField("users", isEqualTo: userIds).getDocuments { [weak self] (snapshot, chatsError) in
            guard let strongSelf = self else { return }
            if let chatsError = chatsError {
                completion(.failure(chatsError))
                return
            }
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
            let data: [String: Any] = [
                "lastMessage": message.text,
                "lastMessageTimestamp": message.created
            ]
            doc.reference.updateData(data) {
                updateError in
                if let updateError = updateError {
                    completion(.failure(updateError))
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
    }
    
    func observeMessages(completion: @escaping (Result<Void, Error>) -> Void) {
        Firestore.firestore().collection("chats").whereField("users", isEqualTo: userIds).getDocuments { [weak self] (snapshot, error) in
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
            strongSelf.messagesListener = doc.reference.collection("thread").order(by: "created").addSnapshotListener { (messagesSnaphot, messagesError) in
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
    
    func setIsTyping(userId: String, isTyping: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        Firestore.firestore().collection("chats").whereField("users", isEqualTo: userIds).getDocuments { [weak self] (snapshot, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents,
                let doc = documents.first else {
                    completion(.failure(strongSelf.unknownError))
                    return
            }
            doc.reference.updateData([userId: isTyping]) { err in
                if let err = err {
                    completion(.failure(err))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func observeIsTyping(userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        isTypingListener = Firestore.firestore().collection("chats").whereField("users", isEqualTo: userIds).addSnapshotListener { [weak self] (snapshot, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents,
                let doc = documents.first else {
                    completion(.failure(strongSelf.unknownError))
                    return
            }
            if let isTyping = doc.data()[userId] as? Bool {
                completion(.success(isTyping))
            } else {
                completion(.success(false))
            }
        }
    }
    
    private func createChatIfNot(completion: @escaping (Error?) -> Void) {
        Firestore.firestore().collection("chats").whereField("users", isEqualTo: userIds).getDocuments { [weak self] (snapshot, chatsError) in
            guard let strongSelf = self else { return }
            if let error = chatsError {
                completion(error)
                return
            }
            guard let documents = snapshot?.documents else {
                completion(strongSelf.unknownError)
                return
            }
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
        messagesListener?.remove()
        isTypingListener?.remove()
    }
}
