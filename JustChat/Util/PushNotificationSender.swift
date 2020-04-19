//
//  PushNotificationSender.swift
//  JustChat
//
//  Created by Alexander Saprykin on 30.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Foundation

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String, senderId: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        guard let url = URL(string: urlString) else { return }
        let paramString: [String : Any] = [
            "to" : token,
            "notification" : ["title" : title, "body" : body],
            "data" : ["senderId" : senderId]
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA8Ma4xwM:APA91bHPgFyMGDfnQOkKZVsgraWSxMSLwajQIMd6CWoNGVviH3KuyNAfr74isMPgQ-i8g3yxaUkNYf_ySzRtfmwmrnjasSfgaygTMuZ4PRGyy6h_ADAViXRKlgzjF52oTbuuq0EN6ODX", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: AnyObject] {
                        print("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
