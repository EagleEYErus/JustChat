//
//  UsersTableViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 23.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit
import Firebase

class UsersTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        checkAuth()
    }
    
    private func checkAuth() {
        if Auth.auth().currentUser == nil {
            showAuth(animated: false)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        return cell
    }
    
    @IBAction func cancelBarButtonItemAction(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        showAuth(animated: true)
    }
}
