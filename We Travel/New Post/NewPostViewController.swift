//
//  NewPostViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 05/09/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewPostViewController: KeyboardHandlingViewController {
    
    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var postTitleTextField: UITextField!
    
    @IBOutlet weak var postDescriptionLabel: UILabel!
    
    @IBOutlet weak var postDescriptionTextView: UITextView!
    
    @IBOutlet weak var filterTagsLabel: UILabel!
    
    @IBOutlet weak var filterTagsTextField: UITextField!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleFields()
        
        postTitleTextField.addDoneButtonOnKeyboard()
        postDescriptionTextView.addDoneButtonOnKeyboard()
        filterTagsTextField.addDoneButtonOnKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        bottomConstraint?.constant += keyboardFrame.height
        
        let filterTagsTextFieldMaxY = filterTagsTextField.frame.maxY
        if filterTagsTextFieldMaxY > keyboardFrame.origin.y {
            let diff = filterTagsTextFieldMaxY - keyboardFrame.origin.y
            print(diff)
            bottomConstraint?.constant = diff + 30 + 20
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        bottomConstraint?.constant = 30
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
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
        postDescriptionTextView.layer.masksToBounds = false
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
    
    func showEmptyFieldsFeedback() {
        let alert = UIAlertController(title: "Atenção", message: "Os campos precisam estar preenchidos para realizar a postagem", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
        
        let post: [String : Any] = [
            "title": postTitle,
            "description": postDescription,
            "tags": tags,
            "postedBy": postedBy,
            "userId": currentUser.uid
        ]
        
        if postTitle.isEmpty || postDescription.isEmpty || filterTags.isEmpty {
            self.dismiss(animated: true, completion: nil)
            self.showEmptyFieldsFeedback()
            print("campos vazios não foi possivel realizar postagem")
        } else {
            var postRef: DocumentReference? = nil
            postRef = db.collection("posts").addDocument(data: post) {error in
                if let error = error {
                    print("erro ao salvar conteúdo da postagem: \(error.localizedDescription) ")
                } else {
                    print("postagem salva com sucesso")
                    if let documentId = postRef?.documentID {
                            postRef?.updateData(["postId": documentId]) { error in
                                if let error = error {
                                    print("Erro ao atualizar postId: \(error.localizedDescription)")
                                } else {
                                    print("postId atualizado com sucesso")
                                }
                            }
                        }
                    self.clearTextFields()
                    NotificationCenter.default.post(name: NSNotification.Name("newPostAdded"), object: nil)
                    
                    if let tabBarController = self.tabBarController {
                        tabBarController.selectedIndex = 0
                    }
                }
            }
        }
    }
}
