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
    
    var messages: String?
    var time: Date?
    
    init(message: MessageHistoryMessagesPayload){
        self.messages = message.message.stringOptional
        self.time = message.timetoken.timetokenDate
    }
}
