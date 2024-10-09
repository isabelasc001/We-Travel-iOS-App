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
    
    
    
    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var postTitleTextField: UITextField!
    
    @IBOutlet weak var postDescriptionLabel: UILabel!
    
    @IBOutlet weak var postDescriptionTextView: UITextView!
    
    @IBOutlet weak var filterTagsLabel: UILabel!
    
    @IBOutlet weak var filterTagsTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleFields()
}
    
    func clearTextFields() {
        postTitleTextField.text = ""
        postDescriptionTextView.text = ""
        filterTagsTextField.text = ""
    }
    
    func styleFields() {
        postTitleTextField.layer.cornerRadius = 10
        postTitleTextField.layer.shadowColor = UIColor.black.cgColor
        postTitleTextField.layer.shadowOpacity = 0.2
        postTitleTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        postTitleTextField.layer.shadowRadius = 4
        postTitleTextField.backgroundColor = .white
        postTitleTextField.layer.borderColor = UIColor.orange.cgColor
        postTitleTextField.layer.borderWidth = 1
        
        postDescriptionTextView.layer.cornerRadius = 10
        postDescriptionTextView.layer.shadowColor = UIColor.black.cgColor
        postDescriptionTextView.layer.shadowOpacity = 0.2
        postDescriptionTextView.layer.shadowOffset = CGSize(width: 0, height: 2)
        postDescriptionTextView.layer.shadowRadius = 4
        postDescriptionTextView.backgroundColor = .white
        postDescriptionTextView.layer.borderColor = UIColor.orange.cgColor
        postDescriptionTextView.layer.borderWidth = 1
        
        filterTagsTextField.layer.cornerRadius = 10
        filterTagsTextField.layer.shadowColor = UIColor.black.cgColor
        filterTagsTextField.layer.shadowOpacity = 0.2
        filterTagsTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        filterTagsTextField.layer.shadowRadius = 4
        filterTagsTextField.backgroundColor = .white
        filterTagsTextField.layer.borderColor = UIColor.orange.cgColor
        filterTagsTextField.layer.borderWidth = 1
        
    }
    
    @IBAction func cancelPostButtonPressed(_ sender: Any) {
        
        clearTextFields()
        
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
           
        }
        print("usuário cancelou a postagem")
    }
    
    @IBAction func PostContentButtonPressed(_ sender: Any) {
        
        let db = Firestore.firestore()
        
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
                self.clearTextFields()
                NotificationCenter.default.post(name: NSNotification.Name("newPostAdded"), object: nil)
                
                if let tabBarController = self.tabBarController {
                    tabBarController.selectedIndex = 0
                    
                }
            }
        }
    }
}
