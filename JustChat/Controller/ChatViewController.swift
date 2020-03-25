//
//  ChatViewController.swift
//  JustChat
//
//  Created by Alexander Saprykin on 24.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Чат"
        
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

//extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
//    func currentSender() -> SenderType {
//        
//    }
//    
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//
//    }
//    
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//
//    }
//}
