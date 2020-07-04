//
//  MyAppMessageAction.swift
//  ChatApplication
//
//  Created by Siddhesh jadhav on 01/07/20.
//  Copyright © 2020 infiny. All rights reserved.
//

import Foundation
import PubNub
import SwiftUI

open class MyAppMessageAction: MessageAction {
    public var type: String
    public var value: String
    
    init(type: String,value: String) {
        self.type = type
        self.value = value
    }
}
