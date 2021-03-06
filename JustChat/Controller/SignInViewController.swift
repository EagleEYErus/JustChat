//
//  SignInViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 22.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit

final class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputsContainerView: UIView!
    @IBOutlet weak var signInButton: LoadingButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let viewModel = SignInViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.disable()
        setupInputsContainerViewLayout()
        setupLoginButtonLayout()
        delegating()
        addTargetToTextFields()
    }
    
    private func setupInputsContainerViewLayout() {
        inputsContainerView.layer.cornerRadius = 5
        inputsContainerView.layer.masksToBounds = true
    }
    
    private func setupLoginButtonLayout() {
        signInButton.layer.cornerRadius = 25
        signInButton.layer.masksToBounds = true
    }
    
    private func delegating() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func addTargetToTextFields() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    
    private func isTextFieldsVerified() -> Bool {
        guard let email = emailTextField.text else { return false }
        if passwordTextField.text?.count ?? 0 <= 5 || !email.isValidEmail {
            return false
        } else {
            return true
        }
    }
    
    @objc private func textFieldDidChange() {
        if isTextFieldsVerified() {
            signInButton.enable()
        } else {
            signInButton.disable()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
          nextField.becomeFirstResponder()
       } else {
          textField.resignFirstResponder()
       }
       return false
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        signInButton.startAnimating()
        viewModel.signIn(email: email, password: password) { [weak self] result in
            self?.signInButton.stopAnimating()
            switch result {
            case .success:
                Switcher.updateRootViewController()
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
}
