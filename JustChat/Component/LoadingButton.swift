//
//  LoadingButton.swift
//  JustChat
//
//  Created by Alexander Saprykin on 25.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit

final class LoadingButton: UIButton {
    
    private var originalButtonText: String?
    private var activityIndicator: UIActivityIndicatorView!
    
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
        addSubview(activityIndicator)
        addConstraints()
    }
    
    private func addConstraints() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
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
