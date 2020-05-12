//
//  Message.swift
//  JustChat
//
//  Created by Alexander Saprykin on 26.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Firebase
import MessageKit

struct Message {
    let id: String
    let text: String
    let created: Timestamp
    let senderId: String
    let senderName: String
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "text": text,
            "created": created,
            "senderId": senderId,
            "senderName": senderName
        ]
    }
}

extension Message {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
            let text = dictionary["text"] as? String,
            let created = dictionary["created"] as? Timestamp,
            let senderId = dictionary["senderId"] as? String,
            let senderName = dictionary["senderName"] as? String else { return nil }
        self.init(id: id, text: text, created: created, senderId: senderId, senderName: senderName)
    }
}

extension Message: MessageType {
    var sender: SenderType {
        return Sender(senderId: senderId, displayName: senderName)
    }
    
    var messageId: String {
        return id
    }
    
    var sentDate: Date {
        return created.dateValue()
    }
    
    var kind: MessageKind {
        return .text(text)
    }
}
