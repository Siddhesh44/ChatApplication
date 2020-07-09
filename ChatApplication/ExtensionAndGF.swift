//
//  ExtensionAndGF.swift
//  ChatApplication
//
//  Created by Siddhesh jadhav on 09/07/20.
//  Copyright © 2020 infiny. All rights reserved.
//

import Foundation
import UIKit

class ExtensionAndGF{
    func pubNubDateFormatter(date: Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = .current
        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
}

extension Date {
    func toNanos() -> UInt64! {
        return UInt64(self.timeIntervalSince1970 * 10000000)
    }
}
