//
//  MessagesViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 11/11/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

struct Chat {
    var chatId: String
    var lastMessage: String
    var timeStamp: Timestamp
    var username: String
    var chatParticipants: [String]
    var userPhotoURL: String
    var hasUnreadMessages: Bool
    var photoURL: String
}

class AppMessagesViewController: UIViewController {

    var chats: [Chat] = []
    
    @IBOutlet weak var chatTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableview.delegate = self
        chatTableview.dataSource = self

        chatTableview.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatsCell")
        fetchChats()
    }
    
    func fetchChats() {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("chats").whereField("chatParticipants", arrayContains: currentUserID).addSnapshotListener { snapshot, error in
            if let error = error {
                print("erro ao buscar conversas \(error.localizedDescription)")
                return
            }
//            self.chats = snapshot?.documents.compactMap { doc in
//                try? doc.data(as: Chat.self)
//            } ?? []
            
            DispatchQueue.main.async {
                self.chatTableview.reloadData()
            }
        }
    }
}

extension AppMessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = chatTableview.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as? ChatTableViewCell else {
            return UITableViewCell()
        }
        
        let chat = chats[indexPath.row]
        cell.configureCell(chat: chat)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = chats[indexPath.row]
            
        let chatViewController = ChatViewController()
        chatViewController.chatId = chat.chatId
        navigationController?.pushViewController(chatViewController, animated: true)
        
    }
}
