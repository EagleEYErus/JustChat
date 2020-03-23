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
    
    private let viewModel = ContactsListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkAuth()
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "contactCell")
    }
    
    private func checkAuth() {
        if let user = Auth.auth().currentUser {
            guard let email = user.email else { return }
            viewModel.fetchContacts(email: email) { [weak self] result in
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell else { return UITableViewCell() }
        
        cell.avatarImageView.loadImageUsingCache(by: viewModel.users[indexPath.row].avatarUrl)
        cell.nameLabel.text = viewModel.users[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    @IBAction func cancelBarButtonItemAction(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        showAuth(animated: true)
    }
}
