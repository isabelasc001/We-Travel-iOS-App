//
//  PostCommentsTableViewCell.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 10/10/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol CommentsContentCellDelegate: AnyObject {
    func deleteComment(_ comment: Comment)
    func navigateToProfile(userId: String, comment: Comment)
    func navigateToChat(participantUID: String, comment: Comment)
}

struct Comment {
    let description: String
    let postedBy: String
    let userId: String
    let postId: String
    var commentId: String
}

class PostCommentsTableViewCell: UITableViewCell {
    
    weak var delegate: CommentsContentCellDelegate?
    var comment: Comment?
    var post: Post?
    
    @IBOutlet weak var postedByLabel: UILabel!
    
    @IBOutlet weak var deleteMyCommentButton: UIButton!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var likeCommentButton: UIButton!
    
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    
    @IBOutlet weak var dislikeCommentButton: UIButton!
    
    @IBOutlet weak var numberOfDislikesLabel: UILabel!
    
    @IBOutlet weak var startChatButton: UIButton!
    
    @IBOutlet weak var visitProfileButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeCommentButton.tintColor = UIColor.green
        dislikeCommentButton.tintColor = UIColor.red
    }
    
    func configureCommentCell(with comment: Comment, post: Post) {
        postedByLabel.text = "Postado por \(comment.postedBy)"
        commentTextView.text = comment.description
        self.comment = comment
        self.post = post
        fetchCommentsLikesDislikesCount()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
            if comment.userId == currentUser.uid {
                deleteMyCommentButton.isHidden = false
            } else {
                deleteMyCommentButton.isHidden = true
            }
    }
    
    func editCommentLikesDislikes(isLike: Bool) {
        guard let commentId = comment?.commentId, let userId = Auth.auth().currentUser?.uid, let postId = post?.postId else { return }
        
        let db = Firestore.firestore()
        let type = isLike ? 1 : -1
        
        let commentLikes = Like(type: type, postId: postId, userId: userId, commentId: commentId)
        
        db.collection("commentLikes").whereField("commentId", isEqualTo: commentId).whereField("postId", isEqualTo: postId).whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("erro ao recuperar likes \(error.localizedDescription)")
                return
            } else {
                if let document = snapshot?.documents.first {
                    document.reference.delete()
                } else {
                    db.collection("commentLikes").addDocument(data: [
                        "type": commentLikes.type,
                        "postId": commentLikes.postId,
                        "userId": commentLikes.userId,
                        "commentId": commentLikes.commentId ?? ""
                    ]) { error in
                        if let error = error {
                            print("erro ao salvar like/dislike \(error.localizedDescription)")
                        }
                    }
                }
                self.fetchCommentsLikesDislikesCount()
            }
        }
    }
    
    func fetchCommentsLikesDislikesCount() {
        guard let commentId = comment?.commentId, let postId = post?.postId else { return }
        let db = Firestore.firestore()
                
        db.collection("commentLikes").whereField("commentId", isEqualTo: commentId).whereField("postId", isEqualTo: postId).getDocuments { snapshot, error in
                if let error = error {
                    print("erro ao buscar likes e dislikes \(error.localizedDescription)")
                } else {
                    var likesCount = 0
                    var dislikescount = 0
                        
                    for document in snapshot?.documents ?? [] {
                        if let type = document.data()["type"] as? Int {
                            if type == 1 {
                                likesCount += 1
                            } else if type == -1 {
                                dislikescount += 1
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.numberOfLikesLabel.text = "\(likesCount)"
                        self.numberOfDislikesLabel.text = "\(dislikescount)"
                }
            }
        }
    }
            
    @IBAction func deleteMyCommentButtonPressed(_ sender: Any) {
        guard let comment = comment else { return }
        print("Botão de deletar pressionado para o comentário: \(comment.description)")
        delegate?.deleteComment(comment)
    }
            
    @IBAction func visitOwnersProfileButtonPressed(_ sender: Any) {
        guard let userId = comment?.userId, let comment = comment else { return }
        delegate?.navigateToProfile(userId: userId, comment: comment)
    }
    
    @IBAction func starChatCommentOwnerButtonPressed(_ sender: Any) {
        guard let participantUID = comment?.userId, let comment = comment else { return }
        delegate?.navigateToChat(participantUID: participantUID, comment: comment)
    }
    
    @IBAction func dislikeCommentButtonPressed(_ sender: Any) {
        editCommentLikesDislikes(isLike: false)
    }
            
    @IBAction func likeCommentButtonPressed(_ sender: Any) {
        editCommentLikesDislikes(isLike: true)
    }
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
                
        }
    }

//        func editCommentLikesDislikes(isLike: Bool) {
//            guard let commentId = comment?.commentId, let userId = Auth.auth().currentUser?.uid, let postId = post?.postId else { return }
//
//            let db = Firestore.firestore()
//            let type = isLike ? 1 : -1
//
//            let commentLikes = Like(type: type, postId: postId, userId: userId, commentId: commentId)
//
//            db.collection("commentLikes").whereField("commentId", isEqualTo: commentId).whereField("postId", isEqualTo: postId).whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
//                if let error = error {
//                    print("erro ao recuperar likes \(error.localizedDescription)")
//                    return
//                } else {
//                    if let document = snapshot?.document.exists {
//                            db.collection("commentLikes").document(postId).collection("commentLikes").document(commentId).updateData([
//                                "userId": commentLikes.userId,
//                                "type": commentLikes.type,
//                                "postId": commentLikes.postId
//                            ]) { error in
//                                if let error = error {
//                                    print("erro ao adicionar like ou dislike \(error.localizedDescription)")
//                                } else {
//                                    DispatchQueue.main.async {
//                                        self.fetchCommentsLikesDislikesCount()
//                                    }
//                                }
//                            }
//                        } else {
//                            db.collection("likes").document(postId).collection("commentLikes").document(commentId).setData([
//                                "userId": commentLikes.userId,
//                                "type": commentLikes.type,
//                                "postId": commentLikes.postId
//                            ]) { error in
//                                if let error = error {
//                                    print("erro ao adicionar like ou dislike \(error.localizedDescription)")
//                                } else {
//                                    DispatchQueue.main.async {
//                                        self.fetchCommentsLikesDislikesCount()
//                                    }
//                                }
//                            }
//                        }
//                }

//    func navigateToChatViewController(with chat: Chat) {
//        guard let windowScene = UIApplication.shared.connectedScenes
//            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
//              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
//              let topController = window.rootViewController else {
//            print("Erro ao encontrar o controlador principal.")
//            return
//        }
//        let navigationController = (topController as? UINavigationController) ?? topController.navigationController
//
//        guard let navController = navigationController else {
//            print("Erro: Controlador de navegação não encontrado.")
//            return
//        }
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else {
//            print("Erro: Não foi possível instanciar a tela de chat.")
//            return
//        }
//
//
//        navController.setViewControllers([chatVC], animated: true)
//    }

//    func fetchOrCreateChat(participantUID: String, completion: @escaping (Chat?) -> Void) {
//        guard let currentUserUID = Auth.auth().currentUser?.uid else {
//            completion(nil)
//            return
//        }
//
//        let chatParticipants = [currentUserUID, participantUID].sorted()
//        let db = Firestore.firestore()
//        let chatsCollection = db.collection("chats")
//        let usersCollection = db.collection("users")
//
//        chatsCollection
//            .whereField("chatParticipants", isEqualTo: chatParticipants)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Erro ao verificar chat: \(error.localizedDescription)")
//                    completion(nil)
//                    return
//                }
//
//                if let document = snapshot?.documents.first {
//
//                    let data = document.data()
//                    let chat = Chat(
//                        chatId: document.documentID,
//                        lastMessage: data["lastMessage"] as? String ?? "",
//                        username: data["username"] as? String ?? "Desconhecido",
//                        chatParticipants: data["chatParticipants"] as? [String] ?? [],
//                        userPhotoURL: data["userPhotoURL"] as? String ?? "",
//                        hasUnreadMessages: data["hasUnreadMessages"] as? Bool ?? false,
//                        photoURL: data["userPhotoURL"] as? String ?? ""
//                    )
//                    completion(chat)
//                } else {
//                    usersCollection.document(participantUID).getDocument { userSnapshot, error in
//                        if let error = error {
//                            print("Erro ao buscar dados do usuário: \(error.localizedDescription)")
//                            completion(nil)
//                            return
//                        }
//
//                        let participantData = userSnapshot?.data()
//                        let participantName = participantData?["displayName"] as? String ?? "Usuário"
//                        let participantPhotoURL = participantData?["photoURL"] as? String ?? ""
//
//                        let newChat = chatsCollection.document()
//                        let chatData: [String: Any] = [
//                            "chatParticipants": chatParticipants,
//                            "lastMessage": "",
//                            "username": participantName, // Nome do outro participante
//                            "userPhotoURL": participantPhotoURL, // Foto do outro participante
//                            "hasUnreadMessages": ["senderUID": true, "receiverUID": false]
//
//                        ]
//                        newChat.setData(chatData) { error in
//                            if let error = error {
//                                print("Erro ao criar chat: \(error.localizedDescription)")
//                                completion(nil)
//                            } else {
//                                let chat = Chat(
//                                    chatId: newChat.documentID,
//                                    lastMessage: "",
//                                    username: participantName,
//                                    chatParticipants: chatParticipants,
//                                    userPhotoURL: participantPhotoURL,
//                                    hasUnreadMessages: false,
//                                    photoURL: participantPhotoURL
//                                )
//                                completion(chat)
//                            }
//                        }
//                    }
//                }
//            }
//    }
    
//    private func navigateToChatViewController(with chat: Chat) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else {
//            print("Erro: Não foi possível instanciar ChatViewController.")
//            return
//        }
//
//        // Configurar o ChatViewController com os dados do chat
//        chatViewController.chatId = chat.chatId
//        chatViewController.title = chat.username
//
//        if let navigationController = self.navigationController {
//            // Navegar para o ChatViewController
//            navigationController.pushViewController(chatViewController, animated: true)
//        } else {
//            // Caso não esteja em um NavigationController, apresentar modally
//            let navigationController = UINavigationController(rootViewController: chatViewController)
//            navigationController.modalPresentationStyle = .fullScreen
//            self.present(navigationController, animated: true, completion: nil)
//        }
//    }

//    func navigateToUserProfile(with userId: String, commentId: String) {
//        guard let windowScene = UIApplication.shared.connectedScenes
//            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
//              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
//              let topController = window.rootViewController else {
//            print("Erro ao encontrar o controlador principal.")
//            return
//        }
//
//        let navigationController = (topController as? UINavigationController) ?? topController.navigationController
//
//        guard let navController = navigationController else {
//            print("Erro: Controlador de navegação não encontrado.")
//            return
//        }
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {
//            print("Erro: Não foi possível instanciar a tela de perfil.")
//            return
//        }
//
//        profileVC.userId = userId
//        profileVC.commentId = comment?.commentId
//        navController.pushViewController(profileVC, animated: true)
//    }
