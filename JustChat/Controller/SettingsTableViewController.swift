//
//  SettingsTableViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 20.04.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit
import Firebase

final class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!

    private let viewModel = SettingsViewModel()
    private var user: Firebase.User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGestureRecognizer()
        checkAuth()
        
        saveBarButtonItem.isEnabled = false
        saveBarButtonItem.title = ""
        
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Не указано", attributes: [.foregroundColor: UIColor.lightGray])
    }
    
    private func checkAuth() {
        if let currentUser = Auth.auth().currentUser {
            user = currentUser
            usernameTextField.text = user.displayName ?? ""
        } else {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() as? SignInViewController {
                vc.modalPresentationStyle = .fullScreen
                vc.delegate = self
                present(vc, animated: false, completion: nil)
            }
        }
    }
    
    private func addGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 0, section: 1) {
            changeAvatar()
        }
        
        if indexPath == IndexPath(row: 1, section: 1) {
            signOut()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func changeAvatar() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func signOut() {
        let alert = UIAlertController(title: "", message: "Вы уверены, что хотите выйти?", preferredStyle: .actionSheet)
        let yesAction = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            try? Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() as? SignInViewController {
                vc.modalPresentationStyle = .fullScreen
                vc.delegate = self
                self.present(vc, animated: false, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange() {
        if usernameTextField.text?.count == 0 || usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == user.displayName {
            saveBarButtonItem.isEnabled = false
            saveBarButtonItem.title = ""
        } else {
            saveBarButtonItem.isEnabled = true
            saveBarButtonItem.title = "Сохранить"
        }
    }
    
    @objc private func hideKeyboard() {
        tableView.endEditing(true)
    }
    
    @IBAction func saveBarButtonItemAction(_ sender: UIBarButtonItem) {
        tableView.endEditing(true)
        guard let username = usernameTextField.text else {
            return
        }
        viewModel.updateUsername(by: user, username: username.trimmingCharacters(in: .whitespacesAndNewlines)) { [weak self] (result) in
            switch result {
            case .success:
                self?.saveBarButtonItem.isEnabled = false
                self?.saveBarButtonItem.title = ""
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
}

extension SettingsTableViewController: SignInViewControllerDelegate {
    func fetchData() {
        checkAuth()
    }
}

extension SettingsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            viewModel.updateAvatar(by: user, image: selectedImage) { [weak self] (result) in
                switch result {
                case .success:
                    self?.dismiss(animated: true, completion: nil)
                    return
                case .failure(let error):
                    self?.dismiss(animated: true, completion: nil)
                    self?.showError(message: error.localizedDescription)
                    return
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
