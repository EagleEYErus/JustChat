//
//  User.swift
//  JustChat
//
//  Created by Alexander Saprykin on 23.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

struct User: Decodable {
    var name: String
    var email: String

    var dictionary: [String: Any] {
        return [
            "name": name,
            "email": email
        ]
    }
}

extension User {
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
            let email = dictionary["email"] as? String else { return nil }
        self.init(name: name, email: email)
    }
}
