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
    
    var messageDataArray = [MessageData]() //ใช้งาน FirDatabase
    
//    var firDataSnapshotArray:[FIRDataSnapshot]! = [FIRDataSnapshot]() //แบบที่2
    var databaseRef:FIRDatabaseReference!
    private var _databaseHandle:FIRDatabaseHandle! = nil
    //MARK: ตั้งuserEmail เพื่อใช้ในการตั้งชื่อเวลา add child
    var userEmail: String = ""
    
    
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
        
//        var messageData = MessageData(msgText: "Test1")
//        messageDataArray.append(messageData)
//        messageData = MessageData(msgText: "Test2")
//        messageDataArray.append(messageData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserEmail()
//        databaseRelease() //เพื่อให้เคลียร์ค่าทิ้งทุกครั้งด้วย
//        databaseInit() //ย้ายทั้ง2อันไป getUserEmail()
    }
    
    func getUserEmail(){
        let firAuthEmail = FIRAuth.auth()?.currentUser?.email
        if firAuthEmail != nil {
            
            userEmail = firAuthEmail!
            userEmail = replaceSpcialCharacter(inputStr: userEmail) //การตั้งชื่อ Child จะใส้ @.[]# ไม่ได้ แต่ใน E-mailมี
            
            databaseRelease()
            databaseInit()
        }
    }
    
    func replaceSpcialCharacter(inputStr: String) -> String {
        var outputStr = inputStr
        
        outputStr = outputStr.replacingOccurrences(of: ".", with: "-dot-")
        outputStr = outputStr.replacingOccurrences(of: "#", with: "-sharp-")
        outputStr = outputStr.replacingOccurrences(of: "$", with: "-dollar-")
        outputStr = outputStr.replacingOccurrences(of: "[", with: "-start-")
        outputStr = outputStr.replacingOccurrences(of: "]", with: "-end-")
        
        return outputStr
    }
    
    func databaseInit(){
        databaseRef = FIRDatabase.database().reference() //ดักพวกที่เป็น childAdd //มีชื่อว่า ChatData -> UPDATE: เปลี่ยนเป็น userEmail ให้ตั้งเป็นชื่อแทน
//        //แบบที่2
//        _databaseHandle = self.databaseRef.child(userEmail).observe(.childAdded, with: { (firebaseSnapshot) in 
//        //เวลาเกิดการ Add data เข้ามาใน Database จะเกิด....
//            self.firDataSnapshotArray.append(firebaseSnapshot) //ขอข้อมูล append เข้าไปใน array
//            let indexPathOfLastRow = IndexPath(row: self.firDataSnapshotArray.count-1, section: 0) //แถวสุดท้าย
//            self.tableView.insertRows(at: [indexPathOfLastRow], with: .automatic)
//            
//        })
        
        _databaseHandle = self.databaseRef.child(userEmail).observe(.value, with: { (firebaseSnapshot) in //.value จะทำงานทั้งหมด ดึงdataทั้งหมดออกมา
            
            self.messageDataArray = [] //เคลียร์Arrayทิ้ง เนื่องจากเวลา Data เข้ามาจะเข้ามาจาก database ซึ่งมีข้อมูลเก่าอยู่แล้ว
            if let snapshot = firebaseSnapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let snapValue = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let messageData = MessageData(priKey: key, data: snapValue)
                        
                        self.messageDataArray.append(messageData)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    
    func databaseRelease(){ //Release ข้อมูลเมื่อออก
        if (_databaseHandle != nil) {
            self.databaseRef.child(userEmail).removeObserver(withHandle: _databaseHandle)
            _databaseHandle = nil //เพื่อ set ว่าให้ database ยังไม่เคย edit
        }
    } //->deinit
    
    
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
    
    //MARK: Send Button
    @IBAction func sendBtn(_ sender: Any) {
        if (inputMessageTxt.text!.characters.count > 0) {
            let messageData = MessageData(msgText: inputMessageTxt.text!, msgDateTime: Const().CurrentDateTimeToStr())
            sendMessage(messageData: messageData)
            inputMessageTxt.text = ""
        }
    }
    
    func sendMessage(messageData: MessageData) {
        
        let dataValue: Dictionary<String, AnyObject> = [
            MessageData.MSGTEXT_ID: messageData.MsgText as AnyObject,
            //MessageData.MSGDATETIME_ID: messageData.MsgDateTime as AnyObject เปลี่ยนให้เป็น timestamp เพื่อทำให้ใช้งานได้พวกคำสั่งต่างๆได้
            MessageData.MSGDATETIME_ID: FIRServerValue.timestamp() as AnyObject
            
        ]
        self.databaseRef.child(userEmail).childByAutoId().setValue(dataValue) //ให้Gen id ที่ไม่ซ้ำกันเอง
    }
    
    
    deinit {
        databaseRelease()
        //Update: แก้ปัญหา Keyboard หลัง logout
        deregisterForKeyboardNotification()
    }
    
    
    //---------------------------------------------------------------------------//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return firDataSnapshotArray.count //แบบที่ 2
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
        
        //แบบที่2
//        let firDataSnapshot = self.firDataSnapshotArray[indexPath.row]
//        let snapshotValue = firDataSnapshot.value as! Dictionary<String, AnyObject>
//        var strText = ""
//        if let tempstrText = snapshotValue[MessageData.MSGTEXT_ID] as! String! {
//            strText = tempstrText
//        }
//        var strDateTime = ""
//        if let tempstrDateTime = snapshotValue[MessageData.MSGDATETIME_ID] as! String! {
//            strDateTime = tempstrDateTime
//        }
//        
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as? ChatVCCell {
//            if (strText != "") {
//                let messageData = MessageData(msgText: strText, msgDateTime: strDateTime)
//                cell.setValue(messageData: messageData)
//            }
//            return cell
//        }
//        else {
//            let cell = ChatVCCell()
//            if (strText != "") {
//                let messageData = MessageData(msgText: strText, msgDateTime: strDateTime)
//                cell.setValue(messageData: messageData)
//            }
//            return cell
//        }
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
