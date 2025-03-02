//
//  HomeViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 03/09/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct Post {
    let title: String
    let description: String
    let tags: [String]
    let postedBy: String
    let userId: String
    let postId: String
}

class HomeViewController: UIViewController {
    
    var posts: [Post] = []
    var filteredPosts: [Post] = []
    var post: Post?
    
    @IBOutlet weak var HomeSearchBar: UISearchBar!
    
    @IBOutlet weak var homeTableView: UITableView!
    
    var userAuth: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        HomeSearchBar.delegate = self
        userLoggedIn()
        fetchPostsDataFirestore()
        
        homeTableView.register(UINib(nibName: "CardsContentTableViewCell", bundle: nil), forCellReuseIdentifier: "CardsContentCell")
        NotificationCenter.default.addObserver(self, selector: #selector (handleNewPostNotifications), name: NSNotification.Name("newPostAdded"), object: nil)
    }
    
    func userLoggedIn() {
        if let user = userAuth {
            print("Usuário logado: \(user.displayName ?? "Sem nome")")
        }
    }
    
    func navigateToPostDetails(for post: Post) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let postDetailsVC = storyboard.instantiateViewController(withIdentifier: "PostDetailsViewController") as? PostDetailsViewController {
//            postDetailsVC.post = post
//            navigationController?.pushViewController(postDetailsVC, animated: true)
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let postDetailsNavController = storyboard.instantiateViewController(withIdentifier: "PostDetailsNavigationController") as? UINavigationController,
           let postDetailsVC = postDetailsNavController.viewControllers.first as? PostDetailsViewController {
            postDetailsVC.post = post
////            navigationController?.pushViewController(postDetailsVC, animated: true)
//            postDetailsNavController.pushViewController(postDetailsVC, animated: true)
            self.present(postDetailsNavController, animated: true, completion: nil)
        }
    }
    
    func fetchPostsDataFirestore() {
        let db = Firestore.firestore()
        
        db.collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("erro ao buscar postagens: \(error.localizedDescription)")
            } else {
                if self.filteredPosts.isEmpty {
                    self.posts = snapshot?.documents.compactMap { document -> Post? in
                        let data = document.data()
                        return Post(
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            tags: data["tags"] as? [String] ?? [],
                            postedBy: data["postedBy"] as? String ?? "Usuário não informado",
                            userId: data["userId"] as? String ?? "Não foi possível reaver o ID do usuário",
                            postId: document.documentID
                        )
                    } ?? []
                    DispatchQueue.main.async {
                        self.homeTableView.reloadData()
                    }
                    
                } else {
                    self.filteredPosts = snapshot?.documents.compactMap { document -> Post? in
                        let data = document.data()
                        return Post(
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            tags: data["tags"] as? [String] ?? [],
                            postedBy: data["postedBy"] as? String ?? "Usuário não informado",
                            userId: data["userId"] as? String ?? "Não foi possível reaver o ID do usuário",
                            postId: document.documentID
                        )
                    } ?? []
                    DispatchQueue.main.async {
                         self.homeTableView.reloadData()
                    }
                }
            }
        }
    }
        @objc func handleNewPostNotifications() {
        fetchPostsDataFirestore()
    }
}

extension HomeViewController: CardsContentCellDelegate {
    func deletePost(_ post: Post) {
        print("Botão de excluir clicado para o post: \(post.title)")
        
        let alert = UIAlertController(title: "Excluir Postagem",
                                      message: "Você tem certeza de que deseja excluir esta postagem? Essa ação não pode ser desfeita.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Excluir", style: .destructive, handler: { _ in
            Firestore.firestore().collection("posts").document(post.postId).delete { error in
                if let error = error {
                    print("Erro ao excluir postagem: \(error.localizedDescription)")
                    self.showDeletionError()
                } else {
                    print("Postagem excluída com sucesso.")
                    self.showDeletionSuccess()
                    self.fetchPostsDataFirestore()
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

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = filteredPosts.isEmpty ? posts[indexPath.row] : filteredPosts[indexPath.row]
            navigateToPostDetails(for: selectedPost)
        }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        homeTableView.separatorStyle = .none
    }
}

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredPosts.isEmpty {
            return posts.count
        } else {
            return filteredPosts.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = homeTableView.dequeueReusableCell(withIdentifier: "CardsContentCell", for: indexPath) as? CardsContentTableViewCell else {
            return UITableViewCell()
        }
        
        if filteredPosts.isEmpty {
            let post = posts[indexPath.row]
            cell.configureCell(with: post) {
                self.navigateToPostDetails(for: post)
            }
            cell.delegate = self
            return cell
        } else {
            let post = filteredPosts[indexPath.row]
            cell.configureCell(with: post) {
                self.navigateToPostDetails(for: post)
            }
            cell.delegate = self
            return cell
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredPosts = posts
        } else {
            
            let delimiters = [", ", " ", " ,", " , ", ","]
            
            var keywords = [searchText]
            for delimiter in delimiters {
                keywords = keywords.flatMap { $0.components(separatedBy: delimiter)}
            }
            
            keywords = keywords.map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}.filter { !$0.isEmpty}
            
            filteredPosts = posts.filter { post in
                let lowercasedTags = post.tags.map { $0.lowercased()}
                return keywords.allSatisfy { keyword in
                    lowercasedTags.contains { tag in
                        tag.contains(keyword.lowercased())
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.homeTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredPosts = posts
        homeTableView.reloadData()
        HomeSearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        HomeSearchBar.resignFirstResponder()
    }
}


