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
        //        NotificationCenter.default.addObserver(self, selector: #selector(reloadChatList), name: Notification.Name("chatLastMessageUpdate"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchChats()
    }
    
    func fetchLastMessage(for chatId: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "sentDate", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Erro ao buscar última mensagem: \(error.localizedDescription)")
                    completion("Conversa vazia")
                    return
                }
                
                if let document = snapshot?.documents.first {
                    let message = document.data()["content"] as? String ?? "Conversa vazia"
                    completion(message)
                } else {
                    completion("Conversa vazia")
                }
            }
    }
    
    func fetchOtherUserInfo(for chat: Chat, completion: @escaping (String, String) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion("Desconhecido", "")
            return
        }

        let otherUserID = chat.chatParticipants.first { $0 != currentUserID } ?? currentUserID

        let db = Firestore.firestore()
        db.collection("users").document(otherUserID).getDocument { document, error in
            if let error = error {
                print("Erro ao buscar dados do outro usuário: \(error.localizedDescription)")
                completion("Desconhecido", "")
                return
            }

            if let data = document?.data() {
                let username = data["displayName"] as? String ?? "Desconhecido"
                let photoURL = data["photoURL"] as? String ?? ""
                completion(username, photoURL)
            } else {
                completion("Desconhecido", "")
            }
        }
    }
    
//    func fetchOtherUserInfo(for chat: Chat, completion: @escaping (String, String) -> Void) {
//        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
//
//        let otherUserID = chat.chatParticipants.first { $0 != currentUserID }
//
//        guard let otherUserID = otherUserID else {
//            print("Outro usuário não encontrado na conversa.")
//            completion("Desconhecido", "")
//            return
//        }
//
//        let db = Firestore.firestore()
//        db.collection("users").document(otherUserID).getDocument { document, error in
//            if let error = error {
//                print("Erro ao buscar dados do outro usuário: \(error.localizedDescription)")
//                completion("Desconhecido", "")
//                return
//            }
//
//            if let data = document?.data() {
//                let username = data["displayName"] as? String ?? "Desconhecido"
//                let photoURL = data["photoURL"] as? String ?? ""
//                completion(username, photoURL)
//            } else {
//                completion("Desconhecido", "")
//            }
//        }
//    }
    
    func fetchChats() {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Usuário não logado ou UID indisponível.")
            return
        }
        
        db.collection("chats")
            .whereField("chatParticipants", arrayContains: currentUserID)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Erro ao buscar conversas: \(error.localizedDescription)")
                    return
                }
                
                // Limpa os chats para evitar duplicações
                var updatedChats: [Chat] = []
                let group = DispatchGroup()
                
                snapshot?.documents.forEach { document in
                    group.enter()
                    let data = document.data()
                    let chatId = document.documentID
                    
                    var chat = Chat(
                        chatId: chatId,
                        lastMessage: data["lastMessage"] as? String ?? "Conversa vazia",
                        username: "", // Preenchido posteriormente
                        chatParticipants: data["chatParticipants"] as? [String] ?? [],
                        userPhotoURL: "", // Preenchido posteriormente
                        hasUnreadMessages: data["hasUnreadMessages"] as? Bool ?? false,
                        photoURL: ""
                    )
                    
                    // Busca informações do outro usuário
                    self.fetchOtherUserInfo(for: chat) { username, photoURL in
                        chat.username = username
                        chat.userPhotoURL = photoURL
                        
                        // Busca última mensagem
                        self.fetchLastMessage(for: chatId) { lastMessage in
                            chat.lastMessage = lastMessage
                            
                            // Adiciona o chat atualizado à lista temporária
                            updatedChats.append(chat)
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    // Atualiza a lista de chats sem duplicações
                    self.chats = updatedChats
                    print("Chats carregados: \(self.chats)")
                    self.chatTableview.reloadData()
                }
            }
    }
}
    
//    func fetchChats() {
//        let db = Firestore.firestore()
//        guard let currentUserID = Auth.auth().currentUser?.uid else {
//            print("Usuário não logado ou UID indisponível.")
//            return
//        }
//
//        db.collection("chats")
//            .whereField("chatParticipants", arrayContains: currentUserID)
//            .addSnapshotListener { snapshot, error in
//                if let error = error {
//                    print("Erro ao buscar conversas: \(error.localizedDescription)")
//                    return
//                }
//
//                self.chats = []
//                let group = DispatchGroup()
//
//                snapshot?.documents.forEach { document in
//                    group.enter()
//                    let data = document.data()
//                    let chatId = document.documentID
//
//                    var chat = Chat(
//                        chatId: chatId,
//                        lastMessage: data["lastMessage"] as? String ?? "Conversa vazia",
//                        username: data["username"] as? String ?? "Desconhecido",
//                        chatParticipants: data["chatParticipants"] as? [String] ?? [],
//                        userPhotoURL: data["userPhotoURL"] as? String ?? "",
//                        hasUnreadMessages: data["hasUnreadMessages"] as? Bool ?? false,
//                        photoURL: data["userPhotoURL"] as? String ?? ""
//                    )
//
//                    self.fetchLastMessage(for: chatId) { lastMessage in
//                        chat.lastMessage = lastMessage
//                        self.chats.append(chat)
//                        group.leave()
//                    }
//                }
//
//                group.notify(queue: .main) {
//                    print("Chats carregados: \(self.chats)")
//                    self.chatTableview.reloadData()
//                }
//            }
//    }



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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            chatViewController.chatId = chat.chatId
            navigationController?.pushViewController(chatViewController, animated: true)
        }
    }
}


//func fetchChats() {
//    let db = Firestore.firestore()
//    guard let currentUserID = Auth.auth().currentUser?.uid else { return }
//
//    db.collection("chats").whereField("chatParticipants", arrayContains: currentUserID).addSnapshotListener { snapshot, error in
//        if let error = error {
//            print("erro ao buscar conversas \(error.localizedDescription)")
//            return
//        }
//        self.chats = snapshot?.documents.compactMap { document -> Chat? in
//            let data = document.data()
//            return Chat(chatId: document.documentID,
//                        lastMessage: data["lastMessage"] as? String ?? "",
//                        username: data["username"] as? String ?? "Desconhecido",
//                        chatParticipants: data["chatParticipants"] as? [String] ?? [],
//                        userPhotoURL: data["userPhotoURL"] as? String ?? "",
//                        hasUnreadMessages: data["hasUnreadMessages"] as? Bool ?? false,
//                        photoURL: data["userPhotoURL"] as? String ?? ""
//            )} ?? []
//
//
//        DispatchQueue.main.async {
//            self.chatTableview.reloadData()
//        }
//    }
//}


//
//    @objc func reloadChatList() {
//        // Recarregue os dados da lista de conversas ou do chat
//        DispatchQueue.main.async {
//            self.chatTableview.reloadData()
//        } // Ou outro componente que exibe a última mensagem
//    }

//    func fetchLastMessage(for chatId: String, completion: @escaping (String) -> Void) {
//        let db = Firestore.firestore()
//        db.collection("chats")
//            .document(chatId)
//            .collection("messages")
//            .order(by: "sentDate", descending: true)
//            .limit(to: 1)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Erro ao buscar última mensagem: \(error.localizedDescription)")
//                    completion("Conversa vazia")
//                    return
//                }
//
//                if let document = snapshot?.documents.first {
//                    let message = document.data()["content"] as? String ?? "Conversa vazia"
//                    completion(message)
//
//                    // Atualizar chats e recarregar célula específica
//                    if let index = self.chats.firstIndex(where: { $0.chatId == chatId }) {
//                        self.chats[index].lastMessage = message
//                        DispatchQueue.main.async {
//                            self.chatTableview.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//                        }
//                    }
//                } else {
//                    completion("Conversa vazia")
//                }
//            }
//    }

//    func fetchLastMessage(for chatId: String, completion: @escaping (String) -> Void) {
//        let db = Firestore.firestore()
//        db.collection("chats")
//            .document(chatId)
//            .collection("messages")
//            .order(by: "sentDate", descending: true)
//            .limit(to: 1)
//            .addSnapshotListener { snapshot, error in
//                if let error = error {
//                    print("Erro ao buscar última mensagem: \(error.localizedDescription)")
//                    completion("Conversa vazia")
//                    return
//                }
//
//                if let document = snapshot?.documents.first {
//                    let message = document.data()["content"] as? String ?? "Conversa vazia"
//                    completion(message)
//                } else {
//                    completion("Conversa vazia")
//                }
//            }
//    }

//    func fetchChats() {
//        let db = Firestore.firestore()
//        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
//
//        db.collection("chats")
//            .whereField("chatParticipants", arrayContains: currentUserID)
//            .addSnapshotListener { snapshot, error in
//                if let error = error {
//                    print("Erro ao buscar conversas: \(error.localizedDescription)")
//                    return
//                }
//
//                self.chats = []
//
//                let group = DispatchGroup()
//
//                snapshot?.documents.forEach { document in
//                    group.enter()
//                    let data = document.data()
//                    let chatId = document.documentID
//
//                    var chat = Chat(
//                        chatId: chatId,
//                        lastMessage: data["lastMessage"] as? String ?? "Conversa vazia",
//                        username: data["username"] as? String ?? "Desconhecido",
//                        chatParticipants: data["chatParticipants"] as? [String] ?? [],
//                        userPhotoURL: data["userPhotoURL"] as? String ?? "",
//                        hasUnreadMessages: data["hasUnreadMessages"] as? Bool ?? false,
//                        photoURL: data["userPhotoURL"] as? String ?? ""
//                    )
//
//                    self.fetchLastMessage(for: chatId) { lastMessage in
//                        chat.lastMessage = lastMessage
//                        self.chats.append(chat)
//                        group.leave()
//                    }
//                }
//
//                group.notify(queue: .main) {
//                    self.chatTableview.reloadData()
//                }
//            }
//    }


//    func fetchChats() {
//        let db = Firestore.firestore()
//        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
//
//        db.collection("chats")
//            .whereField("chatParticipants", arrayContains: currentUserID)
//            .addSnapshotListener { snapshot, error in
//                if let error = error {
//                    print("Erro ao buscar conversas: \(error.localizedDescription)")
//                    return
//                }
//
//                self.chats = []
//
//                let group = DispatchGroup()
//
//                snapshot?.documents.forEach { document in
//                    group.enter()
//                    let data = document.data()
//                    let chatId = document.documentID
//                    var chat = Chat(
//                        chatId: chatId,
//                        lastMessage: data["lastMessage"] as? String ?? "Conversa vazia",
//                        username: data["username"] as? String ?? "Desconhecido",
//                        chatParticipants: data["chatParticipants"] as? [String] ?? [],
//                        userPhotoURL: data["userPhotoURL"] as? String ?? "",
//                        hasUnreadMessages: data["hasUnreadMessages"] as? Bool ?? false,
//                        photoURL: data["userPhotoURL"] as? String ?? ""
//                    )
//
//                    self.fetchLastMessage(for: chatId) { lastMessage in
//                        chat.lastMessage = lastMessage
//
//                        if data["lastMessage"] as? String != lastMessage {
//                            db.collection("chats")
//                                .document(chatId)
//                                .updateData(["lastMessage": lastMessage]) { error in
//                                    if let error = error {
//                                        print("Erro ao atualizar lastMessage: \(error.localizedDescription)")
//                                    }
//                                }
//                        }
//
//                        self.chats.append(chat)
//                        group.leave()
//                    }
//                }
//                group.notify(queue: .main) {
//                    self.chatTableview.reloadData()
//                }
//            }
//    }

//func fetchLastMessage(for chatId: String, completion: @escaping (String) -> Void) {
//    let db = Firestore.firestore()
//    db.collection("chats")
//        .document(chatId)
//        .collection("messages")
//        .order(by: "sentDate", descending: true)
//        .limit(to: 1)
//        .addSnapshotListener { snapshot, error in
//            if let error = error {
//                print("Erro ao buscar última mensagem: \(error.localizedDescription)")
//                completion("Conversa vazia")
//                return
//            }
//
//            if let document = snapshot?.documents.first {
//                let message = document.data()["content"] as? String ?? "Conversa vazia"
//                completion(message)
//            } else {
//                completion("Conversa vazia")
//            }
//        }
//}
//
//func fetchChats() {
//    let db = Firestore.firestore()
//    guard let currentUserID = Auth.auth().currentUser?.uid else { return }
//
//    db.collection("chats")
//        .whereField("chatParticipants", arrayContains: currentUserID)
//        .getDocuments { snapshot, error in
//            if let error = error {
//                print("Erro ao buscar conversas: \(error.localizedDescription)")
//                return
//            }
//
//            self.chats = []
//            var loadingCount = snapshot?.documents.count ?? 0
//
//            snapshot?.documents.forEach { document in
//                let data = document.data()
//                let chatId = document.documentID
//                var chat = Chat(
//                    chatId: chatId,
//                    lastMessage: data["lastMessage"] as? String ?? "Conversa vazia",
//                    username: data["username"] as? String ?? "Desconhecido",
//                    chatParticipants: data["chatParticipants"] as? [String] ?? [],
//                    userPhotoURL: data["userPhotoURL"] as? String ?? "",
//                    hasUnreadMessages: data["hasUnreadMessages"] as? Bool ?? false,
//                    photoURL: data["userPhotoURL"] as? String ?? ""
//                )
//
//                // Monitorar mensagens em tempo real para atualizar a última mensagem
//                self.fetchLastMessage(for: chatId) { lastMessage in
//                    chat.lastMessage = lastMessage
//
//                    if data["lastMessage"] as? String != lastMessage {
//                        db.collection("chats")
//                            .document(chatId)
//                            .updateData(["lastMessage": lastMessage]) { error in
//                                if let error = error {
//                                    print("Erro ao atualizar lastMessage: \(error.localizedDescription)")
//                                }
//                            }
//                    }
//
//                    self.chats.append(chat)
//
//                    // Quando todos os chats tiverem sido carregados, recarregue a tableview
//                    loadingCount -= 1
//                    if loadingCount == 0 {
//                        DispatchQueue.main.async {
//                            self.chatTableview.reloadData()
//                        }
//                    }
//                }
//            }
//        }
//}
//func fetchLastMessage(for chatId: String, completion: @escaping (String) -> Void) {
//    let db = Firestore.firestore()
//    db.collection("chats")
//        .document(chatId)
//        .collection("messages")
//        .order(by: "sentDate", descending: true)
//        .limit(to: 1)
//        .addSnapshotListener { snapshot, error in
//            if let error = error {
//                print("Erro ao buscar última mensagem: \(error.localizedDescription)")
//                completion("Conversa vazia")
//                return
//            }
//
//            if let document = snapshot?.documents.first {
//                let message = document.data()["content"] as? String ?? "Conversa vazia"
//                completion(message)
//            } else {
//                completion("Conversa vazia")
//            }
//        }
//}
//
//func fetchChats() {
//    let db = Firestore.firestore()
//    guard let currentUserID = Auth.auth().currentUser?.uid else { return }
//
//    db.collection("chats")
//        .whereField("chatParticipants", arrayContains: currentUserID)
//        .getDocuments { snapshot, error in
//            if let error = error {
//                print("Erro ao buscar conversas: \(error.localizedDescription)")
//                return
//            }
//
//            self.chats = []
//            var loadingCount = snapshot?.documents.count ?? 0
//
//            snapshot?.documents.forEach { document in
//                let data = document.data()
//                let chatId = document.documentID
//                var chat = Chat(
//                    chatId: chatId,
//                    lastMessage: data["lastMessage"] as? String ?? "Conversa vazia",
//                    username: data["username"] as? String ?? "Desconhecido",
//                    chatParticipants: data["chatParticipants"] as? [String] ?? [],
//                    userPhotoURL: data["userPhotoURL"] as? String ?? "",
//                    hasUnreadMessages: data["hasUnreadMessages"] as? Bool ?? false,
//                    photoURL: data["userPhotoURL"] as? String ?? ""
//                )
//
//                // Monitorar mensagens em tempo real para atualizar a última mensagem
//                self.fetchLastMessage(for: chatId) { lastMessage in
//                    chat.lastMessage = lastMessage
//
//                    if data["lastMessage"] as? String != lastMessage {
//                        db.collection("chats")
//                            .document(chatId)
//                            .updateData(["lastMessage": lastMessage]) { error in
//                                if let error = error {
//                                    print("Erro ao atualizar lastMessage: \(error.localizedDescription)")
//                                }
//                            }
//                    }
//
//                    self.chats.append(chat)
//
//                    // Quando todos os chats tiverem sido carregados, recarregue a tableview
//                    loadingCount -= 1
//                    if loadingCount == 0 {
//                        DispatchQueue.main.async {
//                            self.chatTableview.reloadData()
//                        }
//                    }
//                }
//            }
//        }
//}
