//
//  PushNotificationManager.swift
//  JustChat
//
//  Created by Alexander Saprykin on 30.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import Firebase
import UserNotifications

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    let userID: String
    
    init(userID: String) {
        self.userID = userID
        super.init()
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        Messaging.messaging().delegate = self
        
        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }
    
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            let usersRef = Firestore.firestore().collection("users").document(userID)
            usersRef.setData(["fcmToken": token], merge: true)
        }
    }
        
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        updateFirestorePushTokenIfNeeded()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController,
            let senderId = response.notification.request.content.userInfo["senderId"] as? String,
            let currentUser = Auth.auth().currentUser else {
                return
        }
        
        if let tabBarController = rootViewController as? UITabBarController,
            let navController = tabBarController.selectedViewController as? UINavigationController {
            Firestore.firestore().collection("users").whereField("id", isEqualTo: senderId).getDocuments { (snapshot, error) in
                guard error == nil else {
                    return
                }
                guard let document = snapshot?.documents.first else {
                    return
                }
                guard let user = User(dictionary: document.data()) else { return }
                let viewController = ChatViewController()
                viewController.currentUser = currentUser
                viewController.recipientUser = user
                navController.pushViewController(viewController, animated: true)
            }
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        completionHandler()
    }
}

