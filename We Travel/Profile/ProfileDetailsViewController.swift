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

        // Do any additional setup after loading the view.
    }
    

    @IBAction func cancelOperationButtonPressed(_ sender: Any) {
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
        
        userDocument.setData(userDetails, merge: true) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("dados atualizados com sucesso")
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
