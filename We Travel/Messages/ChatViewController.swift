//
//  ChatViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 11/11/24.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import FirebaseAuth

struct Message: MessageType {
    let chatId: String
    let chatContent: String
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind {
        return .text(chatContent)
    }
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {

    var chatId: String?
    var messages: [MessageType] = []
    var otherUserName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        loadMessages()
    }
    
    func sendMessage(_ text: String) {
        guard let user  = Auth.auth().currentUser, let chatId = chatId else { return }
        let db = Firestore.firestore()
        
        let messageData: [String: Any] = [
            "content": text,
            "senderId": user,
            "sentDate": Timestamp(date: Date())
        ]

        db.collection("chats").document(chatId).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Erro ao enviar mensagem: \(error.localizedDescription)")
                return
            }
            
//            let chatUpdate: [String: Any] = [
//                "lastMessage": ,
//                "lastMessageDate": Timestamp(date: Date())
//            ]
//
//            db.collection("chats").document(chatId).updateData(chatUpdate) { error in
//                if let error = error {
//                    print("Erro ao atualizar lastMessage: \(error.localizedDescription)")
//                } else {
//                    print("lastMessage atualizado com sucesso no Firestore.")
//                }
//            }
        }
    }

    func loadMessages() {
        guard let chatId = chatId else { return }
        let db = Firestore.firestore()

        db.collection("chats").document(chatId).collection("messages")
            .order(by: "sentDate", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print("Erro ao carregar mensagens: \(error?.localizedDescription ?? "Erro desconhecido")")
                    return
                }

                self.messages = snapshot.documents.compactMap { document in
                    let data = document.data()
                    guard
                        let id = data["id"] as? String,
                        let content = data["content"] as? String,
                        let senderId = data["senderId"] as? String,
                        let senderName = data["senderName"] as? String,
                        let sentDate = (data["sentDate"] as? Timestamp)?.dateValue()
                    else {
                        return nil
                    }

                    let sender = Sender(senderId: senderId, displayName: senderName)
                    return Message(chatId: chatId, chatContent: content, sender: sender, messageId: id, sentDate: sentDate)
                }

                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }
            }
    }
}

extension ChatViewController: MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        return Sender(senderId: Auth.auth().currentUser?.uid ?? "", displayName: Auth.auth().currentUser?.displayName ?? "Você")
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
            if let sender = message.sender as? Sender {
                    let initials = String(sender.displayName.prefix(1))
                    avatarView.set(avatar: Avatar(initials: initials))
                }
    }
    
    func displayName(for message: MessageType, at indexPath: IndexPath) -> String? {
            let message = messages[indexPath.row]
            return message.sender.displayName
        }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath) -> UIEdgeInsets {
            return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        }
}

extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let chatId = chatId else { return }
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let messagesCollection = db.collection("chats").document(chatId).collection("messages")
        
        let messageId = UUID().uuidString
        let sentDate = Date()
        let sender = Sender(senderId: currentUser.uid, displayName: currentUser.displayName ?? "Você")
        
        let messageData: [String: Any] = [
            "id": messageId,
            "content": text,
            "senderId": sender.senderId,
            "senderName": sender.displayName,
            "sentDate": Timestamp(date: sentDate),
            "kind": "text"
        ]
        
        messagesCollection.addDocument(data: messageData) { error in
            if let error = error {
                print("Erro ao enviar mensagem: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
            inputBar.inputTextView.text = ""
            NotificationCenter.default.post(name: NSNotification.Name("chatLastMessageUpdate"), object: nil)
        }
    }
}
