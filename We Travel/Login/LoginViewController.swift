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
        
        if Auth.auth().currentUser != nil {
            if keepLoggedInSwitch.isOn {
                print("o usuário esta logado com o firebase authe pode navegar difertamente para a tela principal")
                self.navigateToTabBarcontroller()
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

            // resultado do login com o google e retorno do token unico do user
            guard let user = result?.user, let idToken = user.idToken else {
                print("Falha ao recuperar o token de autenticação do Google.")
                return
            }

            let accessToken = user.accessToken

            // criando as credenciais do firebase
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)

            // login no firebase com as credenciais
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


//////    let signInButton = GIDSignInButton()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupLoginVC()
////        signInButton.translatesAutoresizingMaskIntoConstraints = false
////        setupLoginButton()
//    }
//
////    public func setupLoginButton() {
////        self.view.addSubview(signInButton)
////
////        NSLayoutConstraint.activate([
////                signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
////                signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
////                signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -180),
////                signInButton.heightAnchor.constraint(equalToConstant: 50)
////    ])
////        }
//
//    public func setupLoginVC() {
//        //        googleSignInButton.addTarget(self, action: #selector(LoginButtonPressed), for: .touchUpInside)
//
//        guard let clientID = FirebaseApp.app()?.options.clientID else { print("Não foi possível localizar o clientID")
//            return
//        }
//
//        //clientID do googleservice info.plist
//        let configurationGID = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.configuration = configurationGID
//    }
//
//GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
//    guard error == nil else {
//        // ...
//        return
//
//import UIKit
//import Firebase
//import GoogleSignIn
//
//class LoginViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    @IBAction func googleSignInButtonTapped(_ sender: Any) {
//        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//
//        // Create Google Sign-In configuration object
//        let config = GIDConfiguration(clientID: clientID)
//
//        // Start the sign-in flow
//        GIDSignIn.sharedInstance.signIn(withPresenting: self) {result, error in
//            guard error == nil else {
////                self?.displayMessage(title: "Erro", message: "Algo deu errado")
//                return
//            }
////
//            guard let result = result,
//                  let idToken = result.idToken?.tokenString else {
//                self?.displayMessage(title: "Erro", message: "Não foi possível obter o token do usuário.")
//                return
//            }
//
//            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.accessToken.tokenString)
//
//            // Sign in with Firebase
//            Auth.auth().signIn(with: credential) { authResult, error in
//                if let error = error {
//                    self?.displayMessage(title: "Erro", message: error.localizedDescription)
//                    return
//                }
//
//                // controller de cadastro de infos usuario
//                self?.navigateToUserDetails()
//            }
//        }
//    }
//
//    private func navigateToUserDetails() {
//        // Instantiate the UserDetailsViewController from the storyboard
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let userDetailsVC = storyboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as? UserDetailsViewController else {
//            print("Erro ao instanciar UserDetailsViewController")
//            return
//        }
//
//        // Pass user data if necessary
//        // userDetailsVC.user = Auth.auth().currentUser
//
//        // Push the UserDetailsViewController onto the navigation stack
//        self.navigationController?.pushViewController(userDetailsVC, animated: true)
//    }
//
//    private func displayMessage(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alertController, animated: true)
//    }
//}

//func navigateToHome() {
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//    if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
//        if let currentUser = Auth.auth().currentUser {
//            homeVC.userAuth = currentUser // Passa o usuário logado para a tela Home
//            self.navigationController?.pushViewController(homeVC, animated: true)
//        } else {
//            print("Nenhum usuário logado")
//        }
//    }
//}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


