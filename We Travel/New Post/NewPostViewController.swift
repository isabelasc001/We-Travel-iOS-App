//
//  NewPostViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 05/09/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewPostViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var postTitleTextField: UITextField!
    
    @IBOutlet weak var postDescriptionLabel: UILabel!
    
    @IBOutlet weak var postDescriptionTextView: UITextView!
    
    @IBOutlet weak var filterTagsLabel: UILabel!
    
    @IBOutlet weak var filterTagsTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
}
    
    @IBAction func cancelPostButtonPressed(_ sender: Any) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
        }
        print("usuário cancelou a postagem")
    }
    
    @IBAction func PostContentButtonPressed(_ sender: Any) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let postTitle = postTitleTextField.text ?? "sem título"
        let postDescription = postDescriptionTextView.text ?? "sem descrição"
        let filterTags = filterTagsTextField.text ?? "sem tags de filtragem"
        let postedBy = currentUser.displayName ?? "sem nome"
        
        let tags = filterTags.components(separatedBy: ",").map {$0.trimmingCharacters(in: .whitespaces)}
        
        let post: [String:Any] = [
            "title": postTitle,
            "description": postDescription,
            "tags": tags,
            "postedBy": postedBy,
            "userId": currentUser.uid
        ]
        
        db.collection("posts").addDocument(data: post) {error in
            if let error = error {
                print("erro ao salvar conteúdo da postagem: \(error.localizedDescription) ")
            } else {
                print("postagem salva com sucesso")
                
                if let tabBarController = self.tabBarController {
                    tabBarController.selectedIndex = 0
                    //COMO APAGAR O CONTEUDO DOS CAMPOS QUANDO A POSTAGEM É REALIZADA?
                }
            }
        }
    }
}
