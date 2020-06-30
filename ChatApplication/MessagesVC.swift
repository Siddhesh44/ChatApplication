//
//  MessagesVC.swift
//  ChatApplication
//
//  Created by Siddhesh jadhav on 17/06/20.
//  Copyright © 2020 infiny. All rights reserved.
//

import UIKit
import PubNub

class MessagesVC: UIViewController {
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTxt: UITextField!
    
    var topView = UIView()
    var channelNameLbl = UILabel()
    var indicator = UILabel()
    var timer = Timer()
    
    var pubnubHelper = PubNubHelper()
    var listener: SubscriptionListener?
    var userName:String!
    var channelName: String!
    var messages: [String] = []
    var timeToken: [String] = []
    var userPresence: Timetoken?
    var messageTimeToken: [Timetoken]?
    var isTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTxt.delegate = self
        
        pubnubHelper.pubnubConfig()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setNavBar()
        
        if messages.isEmpty{
            
        }else{
            let numberOfSections = self.messageTableView.numberOfSections
            let numberOfRows = self.messageTableView.numberOfRows(inSection: numberOfSections-1)
            let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
            self.messageTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
        
        //        pubnubHelper.client.fetchMessageActions(channel: channelName) { (result) in
        //            print("$$$$$$$$$$$$$$$$$$$$",result)
        //        }
        
        listener!.didReceiveSubscription = { event in
            switch event {
            case let .signalReceived(signal):
                print("Signal Received from: ",signal.publisher!,"Signal",signal)
                if let userTypingActionSignal = signal.payload.stringOptional{
                    if let user = signal.publisher?.stringOptional{
                        self.indicator.text = "\(user) \(userTypingActionSignal)"
                    }
                }
            default:
                break
            }
        }
        
        
        
        listener!.didReceiveMessage = { (message) in
            
            if(self.channelName == message.channel)
            {
                if let messagesFromUser = message.payload.stringOptional{
                    let messageTime = message.timetoken.timetokenDate
                    UserDefaults.standard.set(messageTime, forKey: "timeToken")
                    let localDate = self.pubnubHelper.pubNubDateFormatter(date: messageTime)
                    
                    self.timeToken.append(localDate)
                    self.messages.append(messagesFromUser)
                }
                self.messageTableView.reloadData()
                
                let numberOfSections = self.messageTableView.numberOfSections
                let numberOfRows = self.messageTableView.numberOfRows(inSection: numberOfSections-1)
                let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
                self.messageTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }
    
    func setNavBar(){
        let navController = navigationController!
        let viewWidth = navController.navigationBar.frame.size.width
        let viewHeight = navController.navigationBar.frame.size.height
        topView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        //topView.backgroundColor = UIColor.red
        channelNameLbl.frame = CGRect(x: 0, y: 0, width: 300, height: 21)
        channelNameLbl.text = channelName
        channelNameLbl.font = UIFont.boldSystemFont(ofSize: 16)
        indicator.frame = CGRect(x: 0, y: 20, width: 300, height: 21)
        //indicator.text = "Indicator"
        indicator.font = UIFont.systemFont(ofSize: 10)
        topView.addSubview(channelNameLbl)
        topView.addSubview(indicator)
        navigationItem.titleView = topView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-menu-vertical-50"), style: .plain, target: self, action: #selector(MessagesVC.menuBtnTapped))
    }
    
    @objc func menuBtnTapped(){
        print("Menu button pressed")
    }
    
    func publishMessage() {
        let messageString: String = messageTxt.text!
        pubnubHelper.client.publish(channel: channelName, message: messageString) { (status) in
            switch status {
            case let .success(response):
                print("Handle successful Publish response: \(response)")
                
                //                let action = MyAppMessageAction(type: "receipt", value: "message_read")
                //
                //                self.pubnubHelper.client.addMessageAction(channel: self.channelName, message: action, messageTimetoken: response.timetoken) { result in
                //                    switch result{
                //                    case let .success(response):
                //                        print("Successfully Message Action Add Response: \(response)")
                //                    case let .failure(error):
                //                        print("Error from failed response: \(error.localizedDescription)")
                //                    }
            //                }
            case let .failure(error):
                print("Handle response error: \(error.localizedDescription)")
            }
        }
        messageTxt.text = ""
    }
    
    @IBAction func sendMessageBtn(_ sender: UIButton) {
        if(messageTxt.text == "" || messageTxt.text == nil){ } else{
            self.publishMessage()
            self.indicator.text = ""
        }
    }
}

extension MessagesVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell", for: indexPath) as! MessagesTableViewCell
        for mt in messageTimeToken!{
            if mt < userPresence!{
                cell.message.text = messages[indexPath.row]
                cell.timeLbl.text = timeToken[indexPath.row]
            }else{
                cell.message.text = messages[indexPath.row]
                cell.timeLbl.text = timeToken[indexPath.row]
                cell.message.textColor = UIColor.red
            }
        }
        return cell
    }
}

extension MessagesVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.count >= 0 && string.count == 1{
            pubnubHelper.client.signal(channel: channelName,message: "is typing...") { result in
                switch result {
                case let .success(response):
                    print("Successful Response: \(response)")
                    self.isTyping = true
                case let .failure(error):
                    print("Failed Response: \(error.localizedDescription)")
                }
            }
        } else if textField.text!.count == 1 && string.count == 0{
            self.isTyping = false
            self.indicator.text = ""
        }
        return true
    }
}


//class MyAppMessageAction: MessageAction {
//    var type: String
//
//    var value: String
//
//    init(type: String,value: String) {
//        self.type = type
//        self.value = value
//    }
//
//}
