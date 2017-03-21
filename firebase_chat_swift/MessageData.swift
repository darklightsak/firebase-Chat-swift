//
//  MessageData.swift
//  firebase_chat_swift
//
//  Created by Surasak Wattanapradit on 3/11/2560 BE.
//  Copyright © 2560 Surasak Wattanapradit. All rights reserved.
//

import Foundation

class MessageData {
    static let MSGTEXT_ID = "Text"
    static let MSGDATETIME_ID = "DateTime"
    
    //ค่าที่ส่งไปใน Message Chat ไม่ได้มีแค่ txt
    private var _msgText: String!
    private var _msgDateTime: String!
    private var _priKey: String! //primery Key
    
    var MsgText:String {
        return _msgText
    }
    
    var MsgDateTime:String {
        return _msgDateTime
    }
    
    init(msgText:String, msgDateTime:String) {
        self._msgText = msgText
        self._msgDateTime = msgDateTime
    }
    
    
    init(priKey: String, data:Dictionary<String, AnyObject>) {
        self._priKey = priKey
        
        if let MsgText = data[MessageData.MSGTEXT_ID] as? String {
            self._msgText = MsgText
        }
        
//        if let MsgDateTime = data[MessageData.MSGDATETIME_ID] as? String {
//            self._msgDateTime = MsgDateTime
//        } ปรับให้เป็นเก็บค่าแบบ Timestamp
        
        if let firtimestamp = data[MessageData.MSGDATETIME_ID] as? TimeInterval {
            let dateTime = Date(timeIntervalSince1970: firtimestamp/1000) //ค่าที่ออกมาเวลา gen จะเป็น millisec 
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E dd/MM/yyyy HH:mm"
            
            self._msgDateTime = dateFormatter.string(from: dateTime)
        }
    }
    
}
