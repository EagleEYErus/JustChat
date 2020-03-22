//
//  SignUpViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 22.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit

final class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputsContainerView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    private let viewModel = SignUpViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.disable()
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
        signUpButton.layer.cornerRadius = 25
        signUpButton.layer.masksToBounds = true
    }
    
    private func delegating() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func addTargetToTextFields() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    
    private func isTextFieldsVerified() -> Bool {
        guard let email = emailTextField.text else { return false }
        if nameTextField.text?.count == 0 || passwordTextField.text?.count ?? 0 <= 5 || !email.isValidEmail {
            return false
        } else {
            return true
        }
    }
    
    @objc private func textFieldDidChange() {
        if isTextFieldsVerified() {
            signUpButton.enable()
        } else {
            signUpButton.disable()
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
    
    @IBAction func closeBarButtonItemAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpBittonAction(_ sender: UIButton) {
        guard let name = nameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        viewModel.signUp(name: name, email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
}
