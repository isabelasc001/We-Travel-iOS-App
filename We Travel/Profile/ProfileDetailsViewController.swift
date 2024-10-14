//
//  ProfileDetailsViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 10/10/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileDetailsViewController: UIViewController {

    @IBOutlet weak var aboutMeTextView: UITextView!
    
    @IBOutlet weak var AddNationalityTextField: UITextField!
    
    @IBOutlet weak var spokenLanguagesTextField: UITextField!
    
    @IBOutlet weak var residencyCountryTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func emptyFields() {
        aboutMeTextView.text = ""
        AddNationalityTextField.text = ""
        spokenLanguagesTextField.text = ""
        residencyCountryTextField.text = ""
    }
    
    @IBAction func cancelOperationButtonPressed(_ sender: Any) {
        self.dismiss(animated: true,completion: nil)
    }
    
    @IBAction func saveDetailsButtonPressed(_ sender: Any) {
        let db = Firestore.firestore()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let aboutMe = aboutMeTextView.text ?? ""
        let userNationality = AddNationalityTextField.text ?? ""
        let spokenLanguages = spokenLanguagesTextField.text ?? ""
        let residencyCountry = residencyCountryTextField.text ?? ""
        let userId = currentUser.uid
        
        let userDetails: [String: Any] = [
            "description": aboutMe,
            "nationality": userNationality,
            "languages": spokenLanguages,
            "residency": residencyCountry,
            "userId": userId
        ]
        
        let userDocument = db.collection("userDetails").document(userId)
        
        if aboutMe.isEmpty || userNationality.isEmpty || spokenLanguages.isEmpty || residencyCountry.isEmpty {
            self.dismiss(animated: true, completion: nil)
            print("Campos vazios o conteúdo não será atualizado")
        } else {
            userDocument.setData(userDetails, merge: false) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.dismiss(animated: true, completion: nil)
                    self.emptyFields()
                    print("dados atualizados com sucesso")
                    NotificationCenter.default.post(name: NSNotification.Name("userDetailsUpdated"), object: nil)
                }
            }
        }
    }
}
