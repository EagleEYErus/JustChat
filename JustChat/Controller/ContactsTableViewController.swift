//
//  UsersTableViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 23.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

final class ContactsTableViewController: UITableViewController {
    
    private let viewModel = ContactListViewModel()
    private var currentUser: Firebase.User!
    private let reuseIdentifier = "contactCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchContacts()
    }
    
    private func registerTableViewCell() {
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }

    private func fetchContacts() {
        if let user = Auth.auth().currentUser {
            guard let email = user.email else { return }
            currentUser = user
            
            viewModel.fetchContacts(email: email) { [weak self] result in
                switch result {
                case .success:
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showError(message: error.localizedDescription)
                }
            }
        } else {
            Switcher.updateRootViewController()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.numberOfRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? ContactTableViewCell else { return UITableViewCell() }
        
        cell.nameLabel.text = viewModel.users[indexPath.row].name
        guard let url = URL(string: viewModel.users[indexPath.row].avatarUrl) else { return cell }
        cell.avatarImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle.fill"), completed: nil)

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
}
