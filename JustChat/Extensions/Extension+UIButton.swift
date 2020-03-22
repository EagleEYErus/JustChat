//
//  Extension+UIButton.swift
//  JustChat
//
//  Created by Alexander Saprykin on 23.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit.UIButton

extension UIButton {
    func enable() {
        isEnabled = true
        alpha = 1.0
    }
    
    func disable() {
        isEnabled = false
        alpha = 0.4
    }
}
