//
//  Message.swift
//  ChatApplication
//
//  Created by Siddhesh jadhav on 27/06/20.
//  Copyright © 2020 infiny. All rights reserved.
//

import Foundation
import PubNub

class Message{
    
    var message: String?
    var messageTime: String?
    var userName: String?
    var timeToken: Timetoken?
    var receiptColor: String?
    
    init(data: [String:Any]){
        message = data["Message"] as? String
        messageTime = data["MessageTime"] as? String
        userName = data["UserName"] as? String
        timeToken = data["MessageTimeToken"] as? Timetoken
        receiptColor = data["ReceiptColor"] as? String
    }
}
