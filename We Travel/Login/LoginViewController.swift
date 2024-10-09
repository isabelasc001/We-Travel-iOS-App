//
//  LoginViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 29/08/24.
////
import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {

    let firebaseDatabase = DatabaseViewController()
    
    @IBOutlet weak var keepLoggedInSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGoogleSignIn()
        
        if let stayLoggedIn = UserDefaults.standard.value(forKey: "stayLoggedIn") as? Bool {
            keepLoggedInSwitch.isOn = stayLoggedIn
            print("usuário quer manter a sessao logada")
        }
        
        DispatchQueue.main.async {
            if Auth.auth().currentUser != nil {
                if self.keepLoggedInSwitch.isOn {
                    print("o usuário esta logado com o firebase auth pode navegar para a tela principal")
                    self.navigateToTabBarcontroller()
                    
                }
            }
        }
    }
    
    //configurando o google sign in para fazer login com o firebase
    private func setupGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    //salvar dados do usuário no firestore
    func saveData() {
        self.firebaseDatabase.saveUserDataToFirestore()
    }
    
    func navigateToTabBarcontroller() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarControllerObject = storyboard.instantiateViewController(withIdentifier: "tabBarControllerID")
        self.navigationController?.setViewControllers([tabBarControllerObject], animated: true)
    }
    
    
    @IBAction func switchButttonPressed(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "stayLoggedIn")
    }
    
    @IBAction func GoogleSignInButtonTapped(_ sender: Any) {//fazendo login com o google sign in
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                print("Erro ao fazer login com Google: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user, let idToken = user.idToken else {
                print("Falha ao recuperar o token de autenticação do Google.")
                return
            }

            let accessToken = user.accessToken

            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Erro ao fazer login no Firebase: \(error.localizedDescription)")
                    return
                } else {
                    self.saveData()
                    print("Usuário logado com sucesso no Firebase")
                }
                
                if let user = authResult?.user {
                    print("usuário obtido do authResult = \(user.uid)")
                    self.navigateToTabBarcontroller()
                } else {
                    print("sem usuário disponivel")
                }
            }
        }
    }
}


