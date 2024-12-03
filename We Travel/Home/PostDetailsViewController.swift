//
//  PostDetailsViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 26/09/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

struct Comment {
    let description: String
    let postedBy: String
    let userId: String
    let postId: String
    var commentId: String
}

struct Like {
    var type: Int
    let postId: String
    let userId: String
    let commentId: String?
}

class PostDetailsViewController: UIViewController {
    
    var post: Post?
    var likes: Like?
    var comments: [Comment] = []
    var postUserId: String?
    var chat: Chat?

    @IBOutlet weak var postTitleLabel: UILabel!

    @IBOutlet weak var postContentTextView: UITextView!
    
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    
    @IBOutlet weak var numberOfDislikesLabel: UILabel!
    
    @IBOutlet weak var insertCommentTextView: UITextView!
    
    @IBOutlet weak var displayCommentsTableView: UITableView!
    
    @IBOutlet weak var tagsTextField: UITextField!
    
    @IBOutlet weak var postedByLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayCommentsTableView.delegate = self
        displayCommentsTableView.dataSource =  self
        configurePostDetails()
        setupStyle()
        updateLikesDislikesCount()
        fetchCommentsForPost()
        
        postUserId = post?.userId
        displayCommentsTableView.register(UINib(nibName: "PostCommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentsCell")
    }
    
    func configurePostDetails() {
        guard let post  = post else { return }

        postTitleLabel.text = post.title
        postContentTextView.text = post.description
        tagsTextField.text = post.tags.joined(separator:", ")
        postedByLabel.text = "Postado por \(post.postedBy)"
    }
    
    func fetchOrCreateChat(participantUID: String, completion: @escaping (Chat?) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        let chatParticipants = [currentUserUID, participantUID].sorted()
        let db = Firestore.firestore()
        let chatsCollection = db.collection("chats")
        let usersCollection = db.collection("users")

        chatsCollection
            .whereField("chatParticipants", isEqualTo: chatParticipants)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Erro ao verificar chat: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                if let document = snapshot?.documents.first {
        
                    let data = document.data()
                    let chat = Chat(
                        chatId: document.documentID,
                        lastMessage: data["lastMessage"] as? String ?? "",
                        username: data["username"] as? String ?? "Desconhecido",
                        chatParticipants: data["chatParticipants"] as? [String] ?? [],
                        userPhotoURL: data["userPhotoURL"] as? String ?? "",
                        hasUnreadMessages: data["hasUnreadMessages"] as? Bool ?? false,
                        photoURL: data["userPhotoURL"] as? String ?? ""
                    )
                    completion(chat)
                } else {
                    usersCollection.document(participantUID).getDocument { userSnapshot, error in
                        if let error = error {
                            print("Erro ao buscar dados do usuário: \(error.localizedDescription)")
                            completion(nil)
                            return
                        }

                        let participantData = userSnapshot?.data()
                        let participantName = participantData?["displayName"] as? String ?? "Usuário"
                        let participantPhotoURL = participantData?["photoURL"] as? String ?? ""

                        let newChat = chatsCollection.document()
                        let chatData: [String: Any] = [
                            "chatParticipants": chatParticipants,
                            "lastMessage": "",
                            "username": participantName, // Nome do outro participante
                            "userPhotoURL": participantPhotoURL, // Foto do outro participante
                            "hasUnreadMessages": []
                        ]
                        newChat.setData(chatData) { error in
                            if let error = error {
                                print("Erro ao criar chat: \(error.localizedDescription)")
                                completion(nil)
                            } else {
                                let chat = Chat(
                                    chatId: newChat.documentID,
                                    lastMessage: "",
                                    username: participantName,
                                    chatParticipants: chatParticipants,
                                    userPhotoURL: participantPhotoURL,
                                    hasUnreadMessages: false,
                                    photoURL: participantPhotoURL
                                )
                                completion(chat)
                            }
                        }
                    }
                }
            }
    }

    
    func updateLikesDislikesCount() {
        guard let postId = post?.postId else { return }
        let db = Firestore.firestore()
        
        db.collection("likes").whereField("postId", isEqualTo: postId).getDocuments { snapshot, error in
            if let error = error {
                print("erro ao recuperar contagem: \(error.localizedDescription)")
                return
            }
            var likesCount = 0
            var dislikesCount = 0
            
            for document in snapshot?.documents ?? [] {
                if let type = document.data()["type"] as? Int {
                    if type == 1 {
                        likesCount += 1
                    } else if type == -1 {
                        dislikesCount += 1
                    }
                }
            }
            self.numberOfLikesLabel.text = ("\(likesCount)")
            self.numberOfDislikesLabel.text = ("\(dislikesCount)")
        }
    }
    
    func editLikeDislike(isLike: Bool) {
        guard let postId = post?.postId, let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let type = isLike ? 1 : -1
        
        let likes = Like(type: type, postId: postId, userId: userId, commentId: nil)
        
        db.collection("likes").whereField("postId", isEqualTo: postId).whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("erro ao realizar contagem de likes e dislikes \(error.localizedDescription)")
                return
            } else {
                if let document = snapshot?.documents.first {
                    document.reference.delete()
                } else {
                    db.collection("likes").addDocument(data: [
                        "postId": likes.postId,
                        "userId": likes.userId,
                        "type": likes.type
                    ]) { error in
                        if let error = error {
                            print("erro ao salvar likes e dislikes: \(error.localizedDescription)")
                        }
                    }
                }
                self.updateLikesDislikesCount()
            }
        }
    }
    
    func navigateToUserProfile(with userId: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            profileVC.userId = userId
            profileVC.post = post
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func setupStyle() {
        insertCommentTextView.layer.borderColor = UIColor.orange.cgColor
        insertCommentTextView.layer.borderWidth = 1
        insertCommentTextView.layer.cornerRadius = 10
    }
    
    func fetchCommentsForPost() {
        guard let postId = post?.postId else { return }
        let db = Firestore.firestore()
        
        db.collection("comments").whereField("postId", isEqualTo: postId).getDocuments { snapshot, error in
            if let error = error {
                print("erro ao recuperar comentários \(error.localizedDescription)")
                return
            } else  {
                self.comments = snapshot?.documents.compactMap { document -> Comment? in let data = document.data()
                    return Comment(description: data["description"] as? String ?? "",
                        postedBy: data["postedBy"] as? String ?? "usuário não informado",
                        userId: data["userId"] as? String ?? "",
                        postId: data["postId"] as? String ?? "",
                        commentId: document.documentID)
                } ?? []
                DispatchQueue.main.async {
                    self.displayCommentsTableView.reloadData()
                }
            }
        }
    }
    
    func navigateToChatViewController(with chat: Chat, participantUID: String) {
        fetchOrCreateChat(participantUID: participantUID) { [weak self] chat in
                guard let self = self, let chat = chat else { return }
                
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                        chatViewController.chatId = chat.chatId
                        chatViewController.otherUserName = chat.username // Se você tiver o nome do outro usuário
                        self.navigationController?.pushViewController(chatViewController, animated: true)
                    }
                }
            }
    }
    
    @IBAction func newChatButtonPressed(_ sender: Any) {
        guard let postUserId = postUserId else {
                print("Erro: postUserId não está definido.")
                return
            }

            fetchOrCreateChat(participantUID: postUserId) { [weak self] chat in
                guard let self = self else { return }

                if let chat = chat {
                    // Navega para a tela de chat
                    self.navigateToChatViewController(with: chat, participantUID: postUserId)
                } else {
                    print("Erro: Não foi possível iniciar ou recuperar o chat.")
                }
            }
    }
    
    @IBAction func visitProfileButtonPressed(_ sender: Any) {
        guard let userId = postUserId else { return }
        navigateToUserProfile(with: userId)
    }
    
    @IBAction func sendPostContentButtonPressed(_ sender: Any) {
        guard let postId = post?.postId, let user = Auth.auth().currentUser else { return }
        
        let description = insertCommentTextView.text ?? ""
        let postedBy = user.displayName ?? "Usuário"
        let userId = user.uid
        
        var newComment = Comment(description: description, postedBy: postedBy, userId: userId, postId: postId, commentId: "")
        
        let db = Firestore.firestore()
        let ref = db.collection("comments").document()
        
        let commentData: [String: Any] = [
            "description": newComment.description,
            "postedBy": newComment.postedBy,
            "userId": newComment.userId,
            "postId": newComment.postId
        ]
        
        if description.isEmpty {
            self.dismiss(animated: true, completion: nil)
            print("comentario vazio não é possivel postar")
        } else {
            ref.setData(commentData) { error in
                if let error = error {
                    print("erro ao salvar comentário \(error.localizedDescription)")
                } else {
                    print("comentário salvo com sucesso")
                    let documentId = ref.documentID
                    ref.updateData(["commentId": documentId]) { error in
                        if let error = error {
                            print("erro ao atualizar commentId \(error.localizedDescription)")
                        } else {
                            print("commentId salvo com sucesso")
                            newComment.commentId = documentId
                            self.comments.append(newComment)
                            DispatchQueue.main.async {
                                self.displayCommentsTableView.reloadData()
                            }
                        }
                    }
                    self.insertCommentTextView.text = ""
                    self.resignFirstResponder()
                }
            }
        }
    }
    
    @IBAction func numberOfLikesButtonPressed(_ sender: Any) {
        editLikeDislike(isLike: true)
        
    }
    
    @IBAction func numberOfDislikesButtonPressed(_ sender: Any) {
        editLikeDislike(isLike: false)
    }
}

extension PostDetailsViewController: CommentsContentCellDelegate {
    func deleteComment(_ comment: Comment) {
        print("Botão excluir comentário clicado em comentário \(comment.description)")
        
        let alert = UIAlertController(title: "Excluir comentário", message: "Você tem certeza que deseja excluir este comentário? Essa ação não pode ser desfeita.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cencelar", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Excluir", style: .destructive, handler: { _ in
            Firestore.firestore().collection("comments").document(comment.commentId).delete { error in
                if let error = error {
                    print("Erro ao deleter comnetário \(error.localizedDescription)")
                    self.showDeletionError()
                } else {
                    print("Comentário excluido com sucesso")
                    self.showDeletionSuccess()
                    self.fetchCommentsForPost()
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showDeletionError() {
        let alert = UIAlertController(title: "Erro",
                                      message: "Não foi possível excluir o conteúdo desejado. Tente novamente mais tarde.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showDeletionSuccess() {
        let alert = UIAlertController(title: "Sucesso", message: "O conteúdo foi excluido com sucesso", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension PostDetailsViewController: UITableViewDelegate {
    
}

extension PostDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = displayCommentsTableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as? PostCommentsTableViewCell else {
            return UITableViewCell()
        }
        
        let comments = comments[indexPath.row]
        if let post = post {
            cell.configureCommentCell(with: comments, post: post)
        }
        cell.delegate = self
        return cell
    }
}
