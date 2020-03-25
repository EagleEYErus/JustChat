//
//  LoadingButton.swift
//  JustChat
//
//  Created by Alexander Saprykin on 25.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit

final class LoadingButton: UIButton {
    
    var originalButtonText: String?
    var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        originalButtonText = titleLabel?.text
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = CGPoint(x: (frame.width - activityIndicator.frame.width) / 2, y: frame.height / 2)
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
    }
    
    func startAnimating() {
        setTitle("", for: .normal)
        isEnabled = false
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        setTitle(originalButtonText, for: .normal)
        isEnabled = true
        activityIndicator.stopAnimating()
    }
}
