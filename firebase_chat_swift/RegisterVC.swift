//
//  RegisterVC.swift
//  firebase_chat_swift
//
//  Created by Surasak Wattanapradit on 3/11/2560 BE.
//  Copyright © 2560 Surasak Wattanapradit. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func registerBtn(_ sender: Any) {
        
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
        
        if confirmPasswordTextField.text!.isEqual(passwordTextField.text!) == false {
            confirmPasswordTextField.backgroundColor = UIColor.yellow
            Const().showAlert(title: "Error", message: "Password ไม่เหมือนกัน", viewController: self)
            return
        }
        else {
            confirmPasswordTextField.backgroundColor = UIColor.white
        }
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion: { (firebaseUser, firebaseError) in
            
            if let error = firebaseError {
                Const().showAlert(title: "Error", message: error.localizedDescription, viewController: self)
                return
            }
            else { //ถ้า password เหมือนกัน
                let alert = UIAlertController(title: "Succeed", message: "Register succeed", preferredStyle: .alert)
                let resultAlert = UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                    
                    self.navigationController!.popViewController(animated: true)//ปิดหน้านี้ ถ้าถูก
                })
                
                alert.addAction(resultAlert)
                self.present(alert, animated: true, completion: nil) //เพื่อให้ Alert ทำงาน
                
                return
            }
        })

    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
