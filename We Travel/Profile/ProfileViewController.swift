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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.borderColor = UIColor.orange.cgColor
        
        loadCurrentUserData()
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
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


