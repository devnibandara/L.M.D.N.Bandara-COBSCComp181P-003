//
//  RegisterViewController.swift
//  NIBM Article
//
//  Created by Kithmal Bulathsinhala on 11/6/19.
//  Copyright © 2019 NIBM. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPass: UITextField!
    
    @IBOutlet weak var txtRePass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        var a = false
        var b = false
        
        if txtPass.text == txtRePass.text {
            
            a = true
            
        } else {
            
            self.showAlert(message: "Passwords don't match")
        }
        
        if(txtPass.text == "" || txtRePass.text == "") {
            self.showAlert(message: "Fields cannot be empty")
            
        } else {
            
            b = true
        }
        
        if a == true && b == true {
            
            
            if ((txtEmail.text?.isEmpty)! || (txtPass.text?.isEmpty)!) {
                self.showAlert(message: "All fields are mandatory!")
                return
            } else {
                Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPass.text!) {
                    (authResult, error) in
                    // ...
                    if error == nil {
                        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                        self.present(vc, animated: true, completion: nil)
                        
                        self.showAlert(message: "Signup Successful!")
                        
                        
                        
                        
                        
                        
                    } else {
                        if let errorCode = AuthErrorCode(rawValue: error!._code) {
                            switch errorCode {
                            case .invalidEmail:
                                
                                self.showAlert(message: "You entered an invalid email!")
                            case .userNotFound:
                                
                                self.showAlert(message: "User not found")
                            case .weakPassword:
                                
                                self.showAlert(message: "Password must have at least 6 charachters")
                            case .emailAlreadyInUse:
                                
                                self.showAlert(message: "Email already in use")
                            default:
                                
                                print("Creating user error \(error.debugDescription)!")
                                self.showAlert(message: "Unexpected error \(errorCode.rawValue) please try again!")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showAlert(message:String)
    {
        
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

}
