//
//  ViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 22.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkAuth()
    }
    
    private func checkAuth() {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() {
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: false, completion: nil)
            }
        }
    }
}
