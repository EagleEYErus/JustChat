//
//  ChatPreview.swift
//  JustChat
//
//  Created by Alexander Saprykin on 27.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Firebase

struct ChatPreview {
    var user: User
    var lastMessage: String?
    var lastMessageTimestamp: Timestamp?
}
