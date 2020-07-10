//
//  MessagesTableViewCell.swift
//  ChatApplication
//
//  Created by Siddhesh jadhav on 17/06/20.
//  Copyright © 2020 infiny. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var bubbleBackgroundView: UIView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var readReceipt: UIImageView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleBackgroundView.layer.cornerRadius = 8
    }
    
    func setMessage(data: Message,readRI:String,ChatBBC: UIColor){
        bubbleBackgroundView.backgroundColor = ChatBBC
        readReceipt.image = UIImage(systemName: readRI)
        message.text = data.message
        timeLbl.text = data.messageTime
        
        if data.receiptColor == "message_Recevied"{
            readReceipt.tintColor = UIColor.red
        }else if data.receiptColor == "message_Read"{
            readReceipt.tintColor = UIColor.blue
        }else if data.receiptColor == "message_Readed"{
            readReceipt.tintColor = UIColor.blue
        }else if data.receiptColor == "message_sent"{
            readReceipt.tintColor = UIColor.gray
        } else if data.receiptColor == "gray"{
            readReceipt.tintColor = UIColor.gray
        }
        
        if ChatBBC == UIColor.green{
            leadingConstraint.constant = 97
            trailingConstraint.constant = 20
        }else{
            leadingConstraint.constant = 20
            trailingConstraint.constant = 97
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
