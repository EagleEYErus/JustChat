//
//  ChatsTableViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 27.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit
import Firebase

final class ChatsTableViewController: UITableViewController {
    
    private let viewModel = ChatListViewModel()
    private var currentUser: Firebase.User!
    private let resuseIdentifier = "chatCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: resuseIdentifier)
        checkAuth()
    }
    
    private func checkAuth() {
        if let user = Auth.auth().currentUser {
            currentUser = user
            viewModel.observeChats(userId: user.uid) { [weak self] result in
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
        return viewModel.numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: resuseIdentifier, for: indexPath) as? ChatTableViewCell else { return UITableViewCell() }

        let currentChat = viewModel.chats[indexPath.row]
        cell.nameLabel.text = currentChat.user.name
        cell.messageLabel.text = currentChat.lastMessage ?? "Сообщений нет"
        if let created = currentChat.lastMessageTimestamp?.dateValue() {
            let dateFormatter = DateFormatter()
            if abs(created.timeIntervalSinceNow) > 60 * 60 * 24 {
                dateFormatter.dateFormat = "dd.MM"
            } else {
                dateFormatter.dateFormat = "HH:mm"
            }
            cell.timeLabel.text = dateFormatter.string(from: created)
        } else {
            cell.timeLabel.text = ""
        }
        guard let url = URL(string: currentChat.user.avatarUrl) else { return cell }
        cell.avatarImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle.fill"), completed: nil)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = ChatViewController()
        viewController.currentUser = currentUser
        viewController.recipientUser = viewModel.chats[indexPath.row].user
        navigationController?.pushViewController(viewController, animated: true)
    }
}
