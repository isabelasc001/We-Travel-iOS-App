//
//  ProfileViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 11/09/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController  {
    
    var myPosts: [Post] = []
    var userId: String?
    var commentId: String?
    var post: Post?
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    @IBOutlet weak var userNationalityTextField: UITextField!
    
    @IBOutlet weak var languagesTextField: UITextField!
    
    @IBOutlet weak var residencyTextField: UITextField!
    
    @IBOutlet weak var displayMyPostsCollectionView: UICollectionView!
    
    @IBOutlet weak var editProfileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.borderColor = UIColor.orange.cgColor
        
        displayMyPostsCollectionView.delegate = self
        displayMyPostsCollectionView.dataSource = self
        
        if let userId = post?.userId {
            loadFullProfile(for: userId)
        } else {
            loadCurrentUserData()
            fetchMyPostsFromFirestore()
        }
                
        displayMyPostsCollectionView.register(UINib(nibName: "MyPostsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyPostContentCell")
        NotificationCenter.default.addObserver(self, selector: #selector (handleContentUpdate), name: NSNotification.Name("userDetailsUpdated"), object: nil)
    }
    
    func editProfileButtonVisibility() {
        guard let currentUser = Auth.auth().currentUser else { return }
        editProfileButton.isHidden = (post?.userId != currentUser.uid)
    }
    
    func loadProfileImage(from url: URL) {
        DispatchQueue.global().async {
            if let data =  try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage.image = image
                }
            }
        }
    }
    
    @objc func handleContentUpdate() {
        loadCurrentUserData()
    }
    
    func fetchMyPostsFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            
        db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("erro ao carregar postagens do usuário \(error.localizedDescription)")
            } else {
                self.myPosts = snapshot?.documents.compactMap { document -> Post? in
                    let data = document.data()
                    return Post (
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        tags: data["tags"] as? [String] ?? [],
                        postedBy: data["postedBy"] as? String ?? "",
                        userId: data["userId"] as? String ?? "",
                        postId: data["postId"] as? String ?? "sem Id da postagem"
                    )
                } ?? []
                DispatchQueue.main.async {
                    self.displayMyPostsCollectionView.reloadData()
                }
            }
        }
    }
    
    func navigateToPostDetails(for post: Post) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let postDetailsNavController = storyboard.instantiateViewController(withIdentifier: "PostDetailsNavigationController") as? UINavigationController,
           let postDetailsVC = postDetailsNavController.viewControllers.first as? PostDetailsViewController {
            postDetailsVC.post = post
            self.present(postDetailsNavController, animated: true, completion: nil)
        }
    }
    
    func loadFullProfile(for userId: String?) {
        guard let userId = userId else { return }
                
            let db = Firestore.firestore()
            let userDocument = db.collection("userDetails").document(userId)
            let profile = db.collection("users")
            
            userDocument.getDocument { (document, error) in
                if let document, document.exists {
                    let data = document.data()
                    self.aboutMeTextView.text = data?["description"] as? String ?? "Usuário sem detalhes"
                    self.userNationalityTextField.text = data?["nationality"] as? String ?? "Usuário sem nacionalidade"
                    self.languagesTextField.text = data?["languages"] as? String ?? "Usuário sem idiomas específicos"
                    self.residencyTextField.text = data?["residency"] as? String ?? "Usuário sem país de residência"
                } else {
                    print("Dados não encontrados \(error?.localizedDescription ?? "Erro inesperado")")
                }
            }
        
        profile.whereField("uid", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("erro ao resgatar dados do gmail \(error.localizedDescription)")
            } else if let document = snapshot?.documents.first {
                if let profileimageUrlString = document.data()["photoURL"] as? String,
                   let profileImageUrl = URL(string: profileimageUrlString) {
                    self.loadProfileImage(from: profileImageUrl)
                }
                let profileName = document.data()["displayName"] as? String
                self.profileName.text = profileName
            }
        }
        
        db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("erro ao carregar postagens do usuário \(error.localizedDescription)")
            } else {
                self.myPosts = snapshot?.documents.compactMap { document -> Post? in
                    let data = document.data()
                    return Post (
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        tags: data["tags"] as? [String] ?? [],
                        postedBy: data["postedBy"] as? String ?? "",
                        userId: data["userId"] as? String ?? "",
                        postId: data["postId"] as? String ?? "sem Id da postagem"
                    )
                } ?? []
                DispatchQueue.main.async {
                    self.displayMyPostsCollectionView.reloadData()
                }
            }
        }
        editProfileButtonVisibility()
    }
    
    func loadCurrentUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        profileName.text = user.displayName ?? "Usuário sem nome disponível"
        
        if let photoURL = user.photoURL {
            loadProfileImage(from: photoURL)
        } else {
            print("Não foi possivel carregar a imagem")
        }
        
        let db = Firestore.firestore()
        let userId = user.uid
        let userDocument = db.collection("userDetails").document(userId)
        
        userDocument.getDocument { (document, error) in
            if let document, document.exists {
                let data = document.data()
                self.aboutMeTextView.text = data?["description"] as? String ?? "Usuário sem detalhes"
                self.userNationalityTextField.text = data?["nationality"] as? String ?? "Usuário sem nacionalidade"
                self.languagesTextField.text = data?["languages"] as? String ?? "Usuário sem idiomas específicos"
                self.residencyTextField.text = data?["residency"] as? String ?? "Usuário sem país de residência"
            } else {
                print("Dados não encontrados \(error?.localizedDescription ?? "Erro inesperado")")
            }
        }
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPost = myPosts[indexPath.row]
        navigateToPostDetails(for: selectedPost)
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        myPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = displayMyPostsCollectionView.dequeueReusableCell(withReuseIdentifier: "MyPostContentCell", for: indexPath) as? MyPostsCollectionViewCell else {
            return UICollectionViewCell()
        }
        let post = myPosts[indexPath.row]
        cell.configureCell(with: post) {
            self.navigateToPostDetails(for: post)
        }
        return cell
    }
}
