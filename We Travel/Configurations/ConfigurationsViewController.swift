//
//  ConfigurationsViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 05/09/24.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

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
    
    
    @IBAction func logoutGoogle(_ sender: Any) {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewControllerObject = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            tabBarController?.navigationController?.setViewControllers([loginViewControllerObject], animated: true)
            UserDefaults.standard.set(false, forKey: "stayLoggedIn")
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


