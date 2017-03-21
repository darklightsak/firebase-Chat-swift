//
//  Const.swift
//  firebase_chat_swift
//
//  Created by Surasak Wattanapradit on 3/11/2560 BE.
//  Copyright © 2560 Surasak Wattanapradit. All rights reserved.
//

import Foundation//constant
import UIKit

class Const {
    
    func showAlert(title:String, message:String, viewController:UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let resultAlert = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(resultAlert)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func CurrentDateTimeToStr() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter.string(from: currentDate)
    }
}

