//
//  ChatVCCell.swift
//  firebase_chat_swift
//
//  Created by Surasak Wattanapradit on 3/11/2560 BE.
//  Copyright © 2560 Surasak Wattanapradit. All rights reserved.
//

import UIKit

class ChatVCCell: UITableViewCell {
    
    @IBOutlet weak var TextLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setValue(messageData:MessageData) { //ค่าที่ส่งไปใน Message Chat ไม่ได้มีแค่ txt
        TextLbl.text = messageData.MsgText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
