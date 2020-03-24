//
//  SignUpViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 22.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit

final class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var inputsContainerView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    private let viewModel = SignUpViewModel()
    private let spinnerView = UIActivityIndicatorView(style: .large)
    private var isAvatarSet = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.disable()
        setupInputsContainerViewLayout()
        setupLoginButtonLayout()
        setupAvatarImageViewLayout()
        delegating()
        addTargetToTextFields()
        addGestureRecognizer()
        setupSpinnerViewLayout()
    }
    
    private func setupSpinnerViewLayout() {
        spinnerView.center.x = view.center.x
        spinnerView.frame.origin.y = inputsContainerView.frame.origin.y - spinnerView.frame.height - 1.5
        spinnerView.color = .white
        view.addSubview(spinnerView)
    }
    
    private func setupInputsContainerViewLayout() {
        inputsContainerView.layer.cornerRadius = 5
        inputsContainerView.layer.masksToBounds = true
    }
    
    private func setupLoginButtonLayout() {
        signUpButton.layer.cornerRadius = 25
        signUpButton.layer.masksToBounds = true
    }
    
    private func setupAvatarImageViewLayout() {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.masksToBounds = true
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
    
    private func addGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(selectAvatarImageView))
        avatarImageView.addGestureRecognizer(recognizer)
    }

    private func isDataInputsVerified() -> Bool {
        guard let email = emailTextField.text else { return false }
        return nameTextField.text?.count != 0 && passwordTextField.text?.count ?? 0 > 5 && email.isValidEmail && isAvatarSet
    }
    
    @objc private func textFieldDidChange() {
        if isDataInputsVerified() {
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
    
    @objc func selectAvatarImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @IBAction func closeBarButtonItemAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpBittonAction(_ sender: UIButton) {
        guard let name = nameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let avararImage = avatarImageView.image else { return }
        spinnerView.startAnimating()
        viewModel.signUp(name: name, email: email, password: password, avatarImage: avararImage) { [weak self] result in
            self?.spinnerView.stopAnimating()
            switch result {
            case .success:
                self?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            avatarImageView.image = selectedImage
            isAvatarSet = true
            if isDataInputsVerified() {
                signUpButton.enable()
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
