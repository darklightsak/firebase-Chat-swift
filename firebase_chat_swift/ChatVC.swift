//
//  ChatVC.swift
//  firebase_chat_swift
//
//  Created by Surasak Wattanapradit on 3/11/2560 BE.
//  Copyright © 2560 Surasak Wattanapradit. All rights reserved.
//

import UIKit
import Firebase

class ChatVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var inputMessageTxt: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var messageDataArray = [MessageData]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputMessageTxt.delegate = self //dissmiss Keyboard
        tableView.delegate = self
        tableView.dataSource = self
        
        if (FIRAuth.auth()?.currentUser == nil) { //ถ้าไม่มีการ login จะให้สั่งคำสั่งนี้

            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginStoryboardID") as! LoginVC //ให้โชว์หน้า Login ก่อน
            let navigationController = UINavigationController(rootViewController: loginVC)
            self.present(navigationController, animated: true, completion: nil) //เพื่อให้แสดง navigationC และให้ LoginVC เป็น root
        }
        
        registerForKeyboardNotification() //เรียกใช้funcเลื่อนTextField ขึ้น-ลง ตามขนาด Keyboard
        
        var messageData = MessageData(msgText: "Test1")
        messageDataArray.append(messageData)
        messageData = MessageData(msgText: "Test2")
        messageDataArray.append(messageData)
    }
    
    override func viewWillDisappear(_ animated: Bool) { //ตอนที่กำลังหายไป
//        deregisterForKeyboardNotification()  Update: มีปัญหา keyboard เปลี่ยนไป deregister หลัง logout
    }
    
    //---------------------------------------------------------------------------//
    
    @IBAction func logoutBtn(_ sender: Any) {
        logOut() //เรียก func logOut
        
        if (FIRAuth.auth()?.currentUser == nil) { //ถ้าไม่มีการ login จะให้สั่งคำสั่งนี้(เมื่อกี้กด logout ไปแล้ว)
            
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginStoryboardID") as! LoginVC //ให้โชว์หน้า Login ก่อน
            let navigationController = UINavigationController(rootViewController: loginVC)
            self.present(navigationController, animated: true, completion: nil) //เพื่อให้แสดง navigationC และให้ LoginVC เป็น root
        }
    }
    
    deinit { //Update: แก้ปัญหา Keyboard หลัง logout
        deregisterForKeyboardNotification()
    }
    
    
    //---------------------------------------------------------------------------//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageData = messageDataArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as? ChatVCCell {
            cell.setValue(messageData: messageData)
            return cell
        }
        else {
            let cell = ChatVCCell()
            cell.setValue(messageData: messageData)
            return cell
        }
    }
    
    //---------------------------------------------------------------------------//
    
    //MARK: dissmiss Keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: เลื่อนTextField ขึ้น-ลง ตามขนาด Keyboard
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    func deregisterForKeyboardNotification() { //เอาregisterForKeyboardNotification()ออก
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    func keyboardWillShow(_ sender:NSNotification) {
        if inputMessageTxt.isEditing {
            if let userInfo = sender.userInfo {
                if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
                    let keyboardOffset = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    if keyboardSize.height == keyboardOffset.height { //ถ้าเท่ากัน
                        if self.view.frame.origin.y == 0 { //ถ้ายังไม่ได้เลื่อน Keyboard
                            UIView.animate(withDuration: 0.15, animations: {
                                self.view.frame.origin.y -= keyboardSize.height
                            })
                        }
                    }
                    else { //ถ้าไม่เท่ากัน keyboardSize กับ keyboardOffset
                        UIView.animate(withDuration: 0.15, animations: { 
                            self.view.frame.origin.y += keyboardSize.height - keyboardOffset.height
                        })
                    }
                }
                else {
                    //no UIKeyboardFrameBeginUserInfoKey
                }
            }
        }
    }
    
    func keyboardWillHide(_ sender:NSNotification) {
        if self.view.frame.origin.y != 0 { //ถ้าไม่เลื่อน(ไม่=0)ถึงจะทำ
            if let userInfo = sender.userInfo {
                if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    self.view.frame.origin.y += keyboardSize.height
                }
                else {
                    //UIKeyboardFrameBeginUserInfoKey
                }
            }
            else {
                //no userInfo dictionary in notification
            }
        }
    }
    
    
    //MARK: logout
    func logOut() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
