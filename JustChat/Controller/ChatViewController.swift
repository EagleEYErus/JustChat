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

final class ChatViewController: MessagesViewController, UITextViewDelegate {
    
    private var viewModel: ChatViewModel!
    var currentUser: Firebase.User!
    var recipientUser: User!
    
    private var timer: Timer?
    private var isTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegating()
        setupLayout()
        viewModel = ChatViewModel(userIds: [currentUser.uid, recipientUser.id].sorted())
        viewModel.observeMessages { [weak self] result in
            switch result {
            case .success:
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToBottom()
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
        viewModel.observeIsTyping(userId: recipientUser.id) { [weak self] result in
            switch result {
            case .success(let isTyping):
                self?.setTypingIndicatorViewHidden(!isTyping, animated: true)
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func delegating() {
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.inputTextView.delegate = self
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
        messageInputBar.inputTextView.keyboardAppearance = .dark
        messageInputBar.sendButton.setTitleColor(.white, for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .highlighted)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !isTyping {
            isTyping = true
            viewModel.setIsTyping(userId: currentUser.uid, isTyping: true) { [weak self] result in
                switch result {
                case .success: break
                case .failure(let error):
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(textFieldStopEditing), userInfo: nil, repeats: false)
    }
    
    @objc private func textFieldStopEditing(sender: Timer) {
        viewModel.setIsTyping(userId: currentUser.uid, isTyping: false) { [weak self] result in
            switch result {
            case .success:
                self?.isTyping = false
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
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
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.white])
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let formatter = DateFormatter()
        formatter.dateFormat = Calendar.current.isDateInToday(message.sentDate) ? "HH:mm" : "HH:mm dd.MM.YYYY"
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(
            string: dateString,
            attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.white])
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
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if isFromCurrentSender(message: message) {
            guard let url = currentUser.photoURL else {
                avatarView.image = UIImage(systemName: "person.crop.circle.fill")
                avatarView.tintColor = .systemGray
                avatarView.backgroundColor = UIColor(named: "backgroundView")
                return
            }
            avatarView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle.fill"), completed: nil)
        } else {
            guard let url = URL(string: recipientUser.avatarUrl) else {
                avatarView.image = UIImage(systemName: "person.crop.circle.fill")
                avatarView.tintColor = .systemGray
                avatarView.backgroundColor = UIColor(named: "backgroundView")
                return
            }
            avatarView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle.fill"), completed: nil)
        }
    }
}

// MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
                let message = Message(
            id: UUID().uuidString,
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            created: Timestamp(),
            senderId: currentUser.uid,
            senderName: currentUser.displayName ?? "Unknown"
        )
        
        viewModel.sendMessage(message: message) { [weak self] result in
            inputBar.inputTextView.text = ""
            switch result {
            case .success:
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToBottom()
                if let fcmToken = self?.recipientUser.fcmToken {
                    let sender = PushNotificationSender()
                    sender.sendPushNotification(to: fcmToken, title: message.sender.displayName, body: message.text, senderId: message.senderId)
                }
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
}
