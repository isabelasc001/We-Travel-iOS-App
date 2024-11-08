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
   
    @IBAction func newChatButtonPressed(_ sender: Any) {
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
        return cell
    }
}
