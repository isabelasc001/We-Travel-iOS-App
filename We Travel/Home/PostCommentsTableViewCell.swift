//
//  PostCommentsTableViewCell.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 10/10/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PostCommentsTableViewCell: UITableViewCell {
    
    var comment: Comment?
    var post: Post?
    var commentUserId: String?
    
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
        commentUserId = comment?.userId
    }
    
    func configureCommentCell(with comment: Comment, post: Post) {
        postedByLabel.text = "Postado por \(comment.postedBy)"
        commentTextView.text = comment.description
        self.comment = comment
        self.post = post
        fetchCommentsLikesDislikesCount()
    }
    
    func navigateToUserProfile(with userId: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            profileVC.userId = userId
            if let navigationController = self.window?.rootViewController as? UINavigationController {
                    navigationController.setViewControllers([profileVC], animated: true)
                }
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
    }
            
    @IBAction func visitCommentsOwnerProfileButtonPressed(_ sender: Any) {
        guard let userId = commentUserId else { return }
        navigateToUserProfile(with: userId)
    }
    
    @IBAction func starChatCommentOwnerButtonPressed(_ sender: Any) {
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
