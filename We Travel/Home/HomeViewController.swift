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
}

class HomeViewController: UIViewController, UISearchBarDelegate {
    
    let db = Firestore.firestore()
    
    var posts: [Post] = []
    
    @IBOutlet weak var HomeSearchBar: UISearchBar!
    
    @IBOutlet weak var homeTableView: UITableView!
    
    var userAuth: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        userLoggedIn()
        fetchPostsDataFirestore()
        
        homeTableView.register(UINib(nibName: "CardsContentTableViewCell", bundle: nil), forCellReuseIdentifier: "CardsContentCell")
        
    }
    
    func userLoggedIn() {
        if let user = userAuth {
            print("Usuário logado: \(user.displayName ?? "Sem nome")")
        }
    }
    
    func fetchPostsDataFirestore() {
        db.collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("erro ao buscar postagens: \(error.localizedDescription)")
            } else {
                self.posts = snapshot?.documents.compactMap { document -> Post? in
                    let data = document.data()
                    return Post(
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        tags: data["tags"] as? [String] ?? [],
                        postedBy: data["postedBy"] as? String ?? "Desconhecido",
                        userId: data["userId"] as? String ?? "Não foi possível reaver o ID do usuário"
                    )
                } ?? []
                self.homeTableView.reloadData()
            }
        }
    }
}
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedPost = posts[indexPath.row]
            
        }

}

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = homeTableView.dequeueReusableCell(withIdentifier: "CardsContentCell", for: indexPath) as? CardsContentTableViewCell else {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        cell.configureCell(with: post)
        return cell
    }


}
