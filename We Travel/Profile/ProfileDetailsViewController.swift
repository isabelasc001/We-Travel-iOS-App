//
//  ProfileDetailsViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 10/10/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileDetailsViewController: KeyboardHandlingViewController {

    @IBOutlet weak var aboutMeTextView: UITextView!
    
    @IBOutlet weak var AddNationalityTextField: UITextField!
    
    @IBOutlet weak var spokenLanguagesTextField: UITextField!
    
    @IBOutlet weak var residencyCountryTextField: UITextField!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        
        aboutMeTextView.addDoneButtonOnKeyboard()
        AddNationalityTextField.addDoneButtonOnKeyboard()
        spokenLanguagesTextField.addDoneButtonOnKeyboard()
        residencyCountryTextField.addDoneButtonOnKeyboard()
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
        
        let residencyCountryTextFieldMaxY = residencyCountryTextField.frame.maxY
        if residencyCountryTextFieldMaxY > keyboardFrame.origin.y {
            let diff = residencyCountryTextFieldMaxY - keyboardFrame.origin.y
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
    
    func emptyFields() {
        aboutMeTextView.text = ""
        AddNationalityTextField.text = ""
        spokenLanguagesTextField.text = ""
        residencyCountryTextField.text = ""
    }
    
    func setupStyle() {
        aboutMeTextView.layer.cornerRadius = 10
        aboutMeTextView.layer.shadowColor = UIColor.black.cgColor
        aboutMeTextView.layer.shadowOpacity = 0.2
        aboutMeTextView.layer.shadowOffset = CGSize(width: 0, height: 2)
        aboutMeTextView.layer.shadowRadius = 4
        aboutMeTextView.layer.masksToBounds = false
        aboutMeTextView.backgroundColor = .white
        aboutMeTextView.layer.borderColor = UIColor.orange.cgColor
        aboutMeTextView.layer.borderWidth = 1
        
        AddNationalityTextField.layer.cornerRadius = 10
        AddNationalityTextField.layer.shadowColor = UIColor.black.cgColor
        AddNationalityTextField.layer.shadowOpacity = 0.2
        AddNationalityTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        AddNationalityTextField.layer.shadowRadius = 4
        AddNationalityTextField.layer.masksToBounds = false
        AddNationalityTextField.backgroundColor = .white
        AddNationalityTextField.layer.borderColor = UIColor.orange.cgColor
        AddNationalityTextField.layer.borderWidth = 1
        
        spokenLanguagesTextField.layer.cornerRadius = 10
        spokenLanguagesTextField.layer.shadowColor = UIColor.black.cgColor
        spokenLanguagesTextField.layer.shadowOpacity = 0.2
        spokenLanguagesTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        spokenLanguagesTextField.layer.shadowRadius = 4
        spokenLanguagesTextField.layer.masksToBounds = false
        spokenLanguagesTextField.backgroundColor = .white
        spokenLanguagesTextField.layer.borderColor = UIColor.orange.cgColor
        spokenLanguagesTextField.layer.borderWidth = 1
        
        residencyCountryTextField.layer.cornerRadius = 10
        residencyCountryTextField.layer.shadowColor = UIColor.black.cgColor
        residencyCountryTextField.layer.shadowOpacity = 0.2
        residencyCountryTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        residencyCountryTextField.layer.shadowRadius = 4
        residencyCountryTextField.layer.masksToBounds = false
        residencyCountryTextField.backgroundColor = .white
        residencyCountryTextField.layer.borderColor = UIColor.orange.cgColor
        residencyCountryTextField.layer.borderWidth = 1
    }
    
    func showDetailsPostingFeedback() {
        let alert = UIAlertController(title: "As alterações não foram salvas", message: "Os campos precisam estar preenchidos para atualizar o perfil", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
            self.showDetailsPostingFeedback()
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
