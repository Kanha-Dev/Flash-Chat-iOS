//
//  LoginViewController.swift
//  Flash Chat iOS13
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var errorTextField: UITextField!
    
    @IBAction func loginPressed(_ sender: UIButton) {
        //Optional Binding
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            //Passing the values to Firebase
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                //Error Handling
                if let currentError = error {
                    self.errorTextField.text = currentError.localizedDescription
                } else {
                    // Navigate to the Chat View
                    self.performSegue(withIdentifier: K.loginSegue, sender: self)
                }
            }
        }
        
    }
}
