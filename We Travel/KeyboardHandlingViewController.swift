//
//  KeyboardHandlingViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 06/12/24.
//

import UIKit

extension UITextField {
    func addDoneButtonOnKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Fechar", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: true)
        
        toolbar.backgroundColor = UIColor.lightGray
        toolbar.tintColor = UIColor.systemOrange
        
        self.inputAccessoryView = toolbar
    }
    
    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
    }
}

extension UITextView {
    func addDoneButtonOnKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Fechar", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: true)
        
        toolbar.backgroundColor = UIColor.lightGray
        toolbar.tintColor = UIColor.systemOrange
        
        self.inputAccessoryView = toolbar
    }
    
    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
    }
}

class KeyboardHandlingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDismissKeyboardGesture()
    }

    func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
