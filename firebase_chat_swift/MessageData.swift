//
//  MessageData.swift
//  firebase_chat_swift
//
//  Created by Surasak Wattanapradit on 3/11/2560 BE.
//  Copyright © 2560 Surasak Wattanapradit. All rights reserved.
//

import Foundation

class MessageData {
    //ค่าที่ส่งไปใน Message Chat ไม่ได้มีแค่ txt
    private var _msgText: String!
    
    var MsgText:String {
        return _msgText
    }
    
    init(msgText:String) {
        self._msgText = msgText
    }
}
