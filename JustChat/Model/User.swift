//
//  User.swift
//  JustChat
//
//  Created by Alexander Saprykin on 23.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

struct User {
    let id: String
    let fcmToken: String?
    let name: String
    let email: String
    let avatarUrl: String

    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "email": email,
            "avatarUrl": avatarUrl
        ]
    }
}

extension User {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
            let name = dictionary["name"] as? String,
            let email = dictionary["email"] as? String,
            let avatarUrl = dictionary["avatarUrl"] as? String else { return nil }
        let fcmToken = dictionary["fcmToken"] as? String
        self.init(id: id, fcmToken: fcmToken, name: name, email: email, avatarUrl: avatarUrl)
    }
}
