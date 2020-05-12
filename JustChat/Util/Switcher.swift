//
//  Switcher.swift
//  OMNI
//
//  Created by Alexander Saprykin on 17.09.2019.
//  Copyright © 2019 AirSoft. All rights reserved.
//

import UIKit.UIViewController
import FirebaseAuth

final class Switcher {
    static func updateRootViewController() {
        var rootViewController : UIViewController?
        
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            rootViewController = storyboard.instantiateInitialViewController()
            if let tabBarController = rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
            }
        } else {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            rootViewController = storyboard.instantiateInitialViewController()
        }
        
        guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else { return }
        window.rootViewController = rootViewController
    }
}
