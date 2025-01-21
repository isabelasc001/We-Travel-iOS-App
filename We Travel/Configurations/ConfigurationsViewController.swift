//
//  ConfigurationsViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 05/09/24.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

class ConfigurationsViewController: UIViewController {
    
    @IBOutlet weak var greetinsLabel: UILabel!
    
    @IBOutlet weak var appVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        greetinsLabel.text = "Olá, \(Auth.auth().currentUser?.displayName ?? "usuário")"
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersionLabel.text = version
        }

    }
    
    func showDeletionConfirmation() {
        let alert = UIAlertController(
            title: "Confirmar ação",
            message: "Tem certeza de que deseja excluir sua conta? Esta ação é permanente e todos os seus dados serão apagados.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Excluir Conta", style: .destructive, handler: { _ in
            self.deleteUserAccount()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showDeletionError() {
        let alert = UIAlertController(
            title: "Erro",
            message: "Erro ao deletar conta permanentemente, tente novamente mais tarde",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Fechar", style: .cancel, handler: nil))
    }
    
    func navigateToLogginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewControllerObject = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.tabBarController?.navigationController?.setViewControllers([loginViewControllerObject], animated: true)
        UserDefaults.standard.set(false, forKey: "stayLoggedIn")
    }
    
    func deleteUserAccount() {
        deleteUserContent { success in
            if success {
                Auth.auth().currentUser?.delete { error in
                    if let error = error {
                        print("Erro ao excluir conta: \(error.localizedDescription)")
                        self.showDeletionError()
                    } else {
                        print("Conta excluída com sucesso!")
                        self.navigateToLogginScreen()
                    }
                }
            } else {
                self.showDeletionError()
            }
        }
    }


    func deleteUserContent(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Erro ao buscar posts: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            snapshot?.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            
          
            db.collection("comments").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
                if let error = error {
                    print("Erro ao buscar comentários: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                snapshot?.documents.forEach { document in
                    batch.deleteDocument(document.reference)
                }
                
                
                db.collection("chats").whereField("chatParticipants", arrayContains: userId).getDocuments { snapshot, error in
                    if let error = error {
                        print("Erro ao buscar chats: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    snapshot?.documents.forEach { document in
                        batch.deleteDocument(document.reference)
                    }
                    
                    
                    db.collection("users").document(userId).delete { error in
                        if let error = error {
                            print("Erro ao apagar perfil do usuário: \(error.localizedDescription)")
                            completion(false)
                            return
                        }
                        
                        
                        batch.commit { error in
                            if let error = error {
                                print("Erro ao confirmar exclusão: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func deleteMyAccountButtonPressed(_ sender: Any) {
        showDeletionConfirmation()
    }
    
    @IBAction func logoutGoogle(_ sender: Any) {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            self.navigateToLogginScreen()
            print("Usuário desconectado com sucesso")
        } catch let signOutError as NSError {
            print("Erro ao desconectar \(signOutError.localizedDescription)")
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


