//
//  RegisterViewController.swift
//  Flash Chat iOS13
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var errorTextField: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        //Optional Binding
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            //Passing the values to Firebase
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                //Error Handling
                if let currentError = error{
                    //Localized is used to translate the Error Message to Local Language
                    self.errorTextField.text = currentError.localizedDescription
                } else {
                    // Navigate to the Chat View
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                }
            }
        }
    }
    
}
