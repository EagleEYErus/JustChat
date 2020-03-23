//
//  UsersTableViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 23.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit
import Firebase

class ContactsTableViewController: UITableViewController {
    
    private let viewModel = ContactsListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        checkAuth()
        viewModel.fetchContacts { [weak self] result in
            switch result {
            case .success:
                self?.tableView.reloadData()
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func checkAuth() {
        if Auth.auth().currentUser == nil {
            showAuth(animated: false)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.numberOfRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        
        cell.imageView?.image = UIImage(systemName: "person")
        cell.textLabel?.text = viewModel.users[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func cancelBarButtonItemAction(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        showAuth(animated: true)
    }
}
