//
//  ChatPreview.swift
//  JustChat
//
//  Created by Alexander Saprykin on 27.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Firebase

struct ChatPreview {
    let user: User
    let lastMessage: String?
    let lastMessageTimestamp: Timestamp?
}
