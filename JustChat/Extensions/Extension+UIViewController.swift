//
//  Extension+UIViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 23.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit.UIViewController

extension UIViewController {
    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showAuth(animated: Bool) {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: animated, completion: nil)
        }
    }
}
