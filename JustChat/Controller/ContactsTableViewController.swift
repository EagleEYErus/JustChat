//
//  UsersTableViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 23.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit
import Firebase

final class ContactsTableViewController: UITableViewController {
    
    private let viewModel = ContactListViewModel()
    private var currentUser: Firebase.User!
    private let spinnerView = UIActivityIndicatorView(style: .large)
    private let reuseIdentifier = "contactCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableViewCell()
        setupSpinnerViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchContacts()
    }
    
    private func setupSpinnerViewLayout() {
        spinnerView.color = .white
        tableView.backgroundView = spinnerView
    }
    
    private func registerTableViewCell() {
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }

    private func fetchContacts() {
        if let user = Auth.auth().currentUser {
            guard let email = user.email else { return }
            currentUser = user
            
            tableView.separatorStyle = .none
            spinnerView.startAnimating()
            
            viewModel.fetchContacts(email: email) { [weak self] result in
                self?.spinnerView.stopAnimating()
                self?.tableView.separatorStyle = .singleLine
                switch result {
                case .success:
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showError(message: error.localizedDescription)
                }
            }
        } else {
            showAuth(animated: false)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.numberOfRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? ContactTableViewCell else { return UITableViewCell() }
        
        cell.avatarImageView.loadImageUsingCache(by: viewModel.users[indexPath.row].avatarUrl)
        cell.nameLabel.text = viewModel.users[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = ChatViewController()
        viewController.currentUser = currentUser
        viewController.recipientUser = viewModel.users[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    @IBAction func cancelBarButtonItemAction(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        showAuth(animated: true)
    }
}
