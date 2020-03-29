//
//  ChatViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 24.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    var viewModel: MessageListViewModel!
    var currentUser: Firebase.User!
    var recipientUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegating()
        setupLayout()
        viewModel = MessageListViewModel(userIds: [currentUser.uid, recipientUser.id].sorted())
        viewModel.observeMessages { [weak self] result in
            switch result {
            case .success:
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToBottom()
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
    
    func delegating() {
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    private func setupLayout() {
        title = recipientUser.name
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.backgroundColor = UIColor(named: "backgroundView")
        
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.backgroundColor = UIColor(named: "backgroundView")
        
        messageInputBar.backgroundView.backgroundColor = UIColor(named: "messageInputBar")
        messageInputBar.inputTextView.backgroundColor = UIColor(named: "messageInputBar")
        messageInputBar.inputTextView.textColor = .white
        messageInputBar.sendButton.setTitleColor(.white, for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .highlighted)
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        return Sender(senderId: currentUser.uid, displayName: currentUser.displayName ?? "Unknown")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.messagesCount
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .purple : .darkGray
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .white
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(id: UUID().uuidString, text: text, created: Timestamp(), senderId: currentUser.uid, senderName: currentUser.displayName ?? "Unknown")
        
        viewModel.sendMessage(message: message) { [weak self] result in
            inputBar.inputTextView.text = ""
            switch result {
            case .success:
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToBottom()
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
}
