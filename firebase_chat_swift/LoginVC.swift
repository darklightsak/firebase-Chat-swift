//
//  LoginVC.swift
//  firebase_chat_swift
//
//  Created by Surasak Wattanapradit on 3/10/2560 BE.
//  Copyright © 2560 Surasak Wattanapradit. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var statusLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self //dismiss Keyboard
        passwordTextField.delegate = self
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //dissmiss Keyboard เมื่อกด return
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //dissmiss Keyboard เมื่อสัมผัส view
        self.view.endEditing(true)
    }
    
    //MARK: Login Button (loginClicked)
    @IBAction func loginBtn(_ sender: Any) {
        
        if (emailTextField.text!.characters.count < 6) {
            Const().showAlert(title: "Error", message: "Email ต้องมากกว่า 6 ตัวอักษร", viewController: self) //Model> Const.swift
            emailTextField.backgroundColor = UIColor.yellow
            return //ออก
        }
        else {
            emailTextField.backgroundColor = UIColor.white
        }
        
        if (passwordTextField.text!.characters.count < 6) {
            Const().showAlert(title: "Error", message: "Password ต้องมากกว่า 6 ตัวอักษร", viewController: self)
            passwordTextField.backgroundColor = UIColor.yellow
            return
        }
        else {
            passwordTextField.backgroundColor = UIColor.white
        }
        
        //MARK: Login Button connect to Firebase
        let email = emailTextField.text
        let passwaord = passwordTextField.text
        FIRAuth.auth()?.signIn(withEmail: email!, password: passwaord!, completion: { (firebaseUser, firebaseError) in
            
            if let error = firebaseError {
                self.statusLbl.text = error.localizedDescription
                Const().showAlert(title: "Error", message: error.localizedDescription, viewController: self)
                return
            }
            else {
                self.statusLbl.text = "Signed in succeed"
                
                self.dismiss(animated: true, completion: nil) //เมื่อ Login เสร็จให้ออก (สามารถใช้ได้เพราะเราตั้งChatเป็นหน้าหลัก)
            }
        })
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
