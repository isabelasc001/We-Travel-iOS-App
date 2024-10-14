//
//  ProfileViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 11/09/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    let firebaseDatabase = DatabaseViewController()
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    @IBOutlet weak var userNationalityTextField: UITextField!
    
    @IBOutlet weak var languagesTextField: UITextField!
    
    @IBOutlet weak var residencyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.borderColor = UIColor.orange.cgColor
        
        loadCurrentUserData()
        
        NotificationCenter.default.addObserver(self, selector: #selector (handleContentUpdate), name: NSNotification.Name("userDetailsUpdated"), object: nil)
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
    
    func loadCurrentUserData() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
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


