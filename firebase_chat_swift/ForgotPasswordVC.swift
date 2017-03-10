//
//  ForgotPasswordVC.swift
//  firebase_chat_swift
//
//  Created by Surasak Wattanapradit on 3/11/2560 BE.
//  Copyright © 2560 Surasak Wattanapradit. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func resetPasswordBtn(_ sender: Any) {
        
        if (emailTextField.text!.characters.count < 6) {
            Const().showAlert(title: "Error", message: "Email ต้องมากกว่า 6 ตัวอักษร", viewController: self) //Model> Const.swift
            emailTextField.backgroundColor = UIColor.yellow
            return //ออก
        }
        else {
            emailTextField.backgroundColor = UIColor.white
            
            //MARK: reset password firebase
            let email = emailTextField.text
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: email!, completion: { (firebaseError) in
                
                if let error = firebaseError {
                    Const().showAlert(title: "Error", message: error.localizedDescription, viewController: self)
                    return
                }
                else {
                    let alert = UIAlertController(title: "Succeed", message: "Reset Password ได้ส่งไปที่ E-mail ของคุณแล้ว", preferredStyle: .alert)
                    let resultAlert = UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                        
                        self.navigationController!.popViewController(animated: true) //ออกจากหน้านี้
                    })
                    alert.addAction(resultAlert)
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
            })
        }

        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
