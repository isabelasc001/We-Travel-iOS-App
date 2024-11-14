//
//  ChatViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 11/11/24.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseMessaging
import FirebaseFirestore
import FirebaseAuth

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(documentData: [String: Any]) {
        let senderId = documentData["senderId"] as? String ?? ""
        let displayName = documentData["displayName"] as? String ?? "Unknown"
        self.sender = Sender(senderId: senderId, displayName: displayName)
        
        self.messageId = documentData["messageId"] as? String ?? UUID().uuidString
        self.sentDate = (documentData["sentDate"] as? Timestamp)?.dateValue() ?? Date()
        self.kind = .text(documentData["kind"] as? String ?? "")
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
}

extension ChatViewController: MessagesDisplayDelegate, MessagesDataSource, MessagesLayoutDelegate {
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let initials = String(message.sender.displayName.prefix(1))
        avatarView.set(avatar: Avatar(initials: initials))
    }
    
    var currentSender: MessageKit.SenderType {
        return Sender(senderId: Auth.auth().currentUser?.uid ?? "", displayName: Auth.auth().currentUser?.displayName ?? "Você")
        
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let chatId = chatId, let userId = Auth.auth().currentUser?.uid else {return}
        
        let db = Firestore.firestore()
        
        let messageId = UUID().uuidString
        let messageData: [String: Any] = [
            "senderId": userId,
            "displayName": Auth.auth().currentUser?.displayName ?? "Unknown",
            "messageId": messageId,
            "sentDate": Timestamp(date: Date()),
            "kind": text
        ]
        
        db.collection("chats").document(chatId).collection("messages").document(messageId).setData(messageData) { error in
            if let error = error {
                print("erro ao enviar mensagem: \(error.localizedDescription)")
                return
            }
            inputBar.inputTextView.text = ""
        }
    }
}

extension ChatViewController {
    
    func loadMessages() {
        guard let chatId = chatId else { return }
        
        let db = Firestore.firestore()
        
        db.collection("chats").document(chatId).collection("messages")
            .order(by: "sentDate", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self.messages = documents.compactMap { doc -> Message? in
                    let data = doc.data()
                    return Message(documentData: data)
                }
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
            }
    }
}

//    func fetchMessages() {
//        guard let chatId = chatId else {return}
//
//        Firestore.firestore().collection("chats").document(chatId).collection("messages").order(by: "sentDate").addSnapshotListener { [weak self] snapshot, error in
//            guard let self = self, let documents = snapshot?.documents else {
//                print("erro ao buscar mensagens: \(error?.localizedDescription ?? "erro desconhecido")")
//                return
//            }
////            self.messages = documents.compactMap { doc -> Message? in
////                let data = doc.data()
//////                guard
//////                    let senderId = data["senderId"] as? String
//////                    let display
////             return
//            }
//        }

//    func currentSender() -> SenderType {
//            return Sender(senderId: Auth.auth().currentUser?.uid ?? "", displayName: Auth.auth().currentUser?.displayName ?? "Você")
//
//        guard let user = Auth.auth().currentUser else {
//            fatalError("usuário não autenticado")
//        }
//        return Sender(senderId: user.uid, displayName: user.displayName ?? "Usuário")
//        }

/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
}
*/
