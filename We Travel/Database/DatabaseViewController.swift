//
//  DatabaseViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 10/09/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class DatabaseViewController: UIViewController {

    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func saveUserDataToFirestore() {
        guard let user = Auth.auth().currentUser else { return }

        let userData: [String: Any] = [
            "uid": user.uid,
            "displayName": user.displayName ?? "",
            "email": user.email ?? "",
            "photoURL": user.photoURL?.absoluteString ?? ""
        ]

        // Armazena os dados do usuário no Firestore
        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                print("Erro ao salvar dados do usuário no Firestore: \(error.localizedDescription)")
            } else {
                print("Dados do usuário salvos com sucesso!")
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

}
