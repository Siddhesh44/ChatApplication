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
    
    var pubnubHelper = PubNubHelper()
    
    var topView = UIView()
    var channelNameLbl = UILabel()
    var indicator = UILabel()
    
    var client: PubNub!
    var listener: SubscriptionListener?
    var userName:String!
    var channelName: String!
    var loadedMessages: [MessageHistoryMessagesPayload] = []
    
    var messagesData = [Message]()
    var isUserEditingMessage: Bool = false
    var selectedMessageTimetoken: Timetoken?
    var readRecepitColor = UIColor.gray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pubnubHelper.pubnubDelegate = self
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTxt.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setNavBar()
        
        print("messages on channel",loadedMessages)
        
        for m in loadedMessages{
            let date = m.timetoken.timetokenDate
            let localDate = pubnubHelper.pubNubDateFormatter(date: date)
            
            let message = m.message.stringOptional!
            let messageTime = localDate
            let userName = m.meta!.stringOptional!
            let messageTimeToken = m.timetoken
            
           // print("Data",message,messageTimeToken,messageTime,userName)
            
            let md = Message(data: ["Message":message,"MessageTime":messageTime,"UserName":userName,"MessageTimeToken":messageTimeToken])
            
            messagesData.append(md)
        }
        
        //        client.fetchMessageActions(channel: channelName) { (result) in
        //            print("Message Action",result)
        //        }
        
        if let  lastTimeToken = loadedMessages.last?.timetoken.timetokenDate{
            let currentTimeToken = Date()
            let start = loadedMessages.last!.timetoken
            let end = Timetoken(Date().toNanos())
            
            if currentTimeToken > lastTimeToken{
                print("need to load messages")
                client.fetchMessageHistory(for: [channelName],max: 25,start: start,end: end,metaInResponse: true ) { (result) in
                    switch result{
                    case let .success(Response):
                        if let missingMessages = Response[self.channelName]?.messages{
                            for m in missingMessages{
                                
                                let date = m.timetoken.timetokenDate
                                let localDate = self.pubnubHelper.pubNubDateFormatter(date: date)
                                
                                let message = m.message.stringOptional!
                                let messageTime = localDate
                                let userName = m.meta!.stringOptional!
                                let messageTimeToken = m.timetoken
                                
                                let md = Message(data: ["Message":message,"MessageTime":messageTime,"UserName":userName,"MessageTimeToken":messageTimeToken])
                                
                                self.messagesData.append(md)
                            }
                        }
                        self.messageTableView.reloadData()
                        self.manageTable()
                    case let .failure(Error):
                        print(Error)
                    }
                }
            }else{
                print("you are upto date")
            }
        }
        
        manageTable()
        manageMessageActions()
        
        listener!.didReceiveSubscription = { event in
            switch event {
            case let .signalReceived(signal):
                print("Signal Received from: ",signal.publisher!,"Signal",signal)
                if let userTypingActionSignal = signal.payload.stringOptional{
                    if let user = signal.publisher?.stringOptional{
                        if user == self.userName{
                        } else if userTypingActionSignal == "is typing..."{
                            self.indicator.text = "\(user) \(userTypingActionSignal)"
                        } else{
                            self.indicator.text = ""
                        }
                    }
                }
            default:
                break
            }
            
        }
        
        listener!.didReceiveMessage = { (message) in
            if let messagesFromUser = message.payload.stringOptional{
                let messageTime = message.timetoken.timetokenDate
                let localDate = self.pubnubHelper.pubNubDateFormatter(date: messageTime)
                if message.userMetadata!.stringOptional! != self.userName{
                    let md = Message(data: ["Message":messagesFromUser,"MessageTime":localDate,"UserName":message.userMetadata!.stringOptional!,"MessageTimeToken":message.timetoken])
                    self.messagesData.append(md)
                }
            }
            if message.publisher?.stringOptional! != self.userName{
                let action = MyAppMessageAction(type: "receipt", value: "message_Recevied")
                self.client.addMessageAction(channel: self.channelName, message: action, messageTimetoken: message.timetoken) { result in
                    switch result{
                    case let .success(response):
                        print("message Recevied: \(response)")
                    case let .failure(error):
                        print("Error from failed response: \(error.localizedDescription)")
                    }
                }
            }
            self.messageTableView.reloadData()
            self.manageTable()
        }
    }
    
    func setNavBar(){
        let navController = navigationController!
        let viewWidth = navController.navigationBar.frame.size.width
        let viewHeight = navController.navigationBar.frame.size.height
        topView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        channelNameLbl.frame = CGRect(x: 0, y: 0, width: 300, height: 21)
        channelNameLbl.text = channelName
        channelNameLbl.font = UIFont.boldSystemFont(ofSize: 16)
        indicator.frame = CGRect(x: 0, y: 20, width: 300, height: 21)
        indicator.font = UIFont.systemFont(ofSize: 10)
        topView.addSubview(channelNameLbl)
        topView.addSubview(indicator)
        navigationItem.titleView = topView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-menu-vertical-50"), style: .plain, target: self, action: #selector(MessagesVC.menuBtnTapped))
    }
    
    func manageTable(){
        if self.messagesData.isEmpty{ }else{
            let numberOfSections = self.messageTableView.numberOfSections
            let numberOfRows = self.messageTableView.numberOfRows(inSection: numberOfSections-1)
            let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
            self.messageTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    @objc func menuBtnTapped(){
        print("Menu button pressed")
    }
    
    func publishMessage() {
        let messageString: String = messageTxt.text!
        client.publish(channel: channelName, message: messageString,meta: userName) { (status) in
            switch status {
            case let .success(response):
                let messageTime = response.timetoken.timetokenDate
                let localDate = self.pubnubHelper.pubNubDateFormatter(date: messageTime)
                
                let md = Message(data: ["Message":messageString,"MessageTime":localDate,"UserName": self.userName!,"MessageTimeToken":response.timetoken])
                self.messagesData.append(md)
                
                //                let action = MyAppMessageAction(type: "receipt", value: "message_sent")
                //                self.client.addMessageAction(channel: self.channelName, message: action, messageTimetoken: response.timetoken) { result in
                //                    switch result{
                //                    case let .success(response):
                //                        print("message sent: \(response)")
                //                    case let .failure(error):
                //                        print("Error from failed response: \(error.localizedDescription)")
                //                    }
                //                }
                self.messageTableView.reloadData()
                self.manageTable()
            case let .failure(error):
                print("Handle response error: \(error.localizedDescription)")
            }
        }
        messageTxt.text = ""
    }
    
    func manageMessageActions(){
        
        listener!.didReceiveMessageAction = { event in
            print("didReceiveMessageAction",event)
            if event.associatedValue.type.stringOptional! == "update"{
                let newMessageTimeToken = event.associatedValue.messageTimetoken
                
                if let index = self.messagesData.firstIndex(where: { $0.timeToken == newMessageTimeToken}) {
                    self.messagesData[index].message = event.associatedValue.value.stringOptional!
                }
                self.messageTableView.reloadData()
                
            }  else if (event.associatedValue.type.stringOptional! == "receipt" && event.associatedValue.value.stringOptional! == "message_Recevied"){
                if event.associatedValue.uuid != self.userName{
                    self.readRecepitColor = UIColor.red
                    self.messageTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func sendMessageBtn(_ sender: UIButton) {
        
        if messageTxt.text == "" || messageTxt.text == nil{
            print("TextField Is Empty")
        }else{
            if isUserEditingMessage{
                print("EditingMessage")
                let editedText:String = messageTxt.text!
                let action = MyAppMessageAction(type: "update", value: editedText)
                client.addMessageAction(channel: channelName, message: action, messageTimetoken: selectedMessageTimetoken!) { (result) in
                    switch result {
                    case let .success(response):
                        print("Successful At Editing Message: \(response)")
                    case let .failure(error):
                        print("Error occured At Editing Message: \(error.localizedDescription)")
                    }
                }
                messageTxt.text = ""
                isUserEditingMessage = false
            } else {
                print("PublishingMessage")
                self.publishMessage()
                self.indicator.text = ""
                client.signal(channel: channelName,message: "done typing") { result in
                    switch result {
                    case let .success(response):
                        print("Successful Response: \(response)")
                    case let .failure(error):
                        print("Failed Response: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
}

extension MessagesVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell", for: indexPath) as! MessagesTableViewCell
        let currentUser = messagesData[indexPath.row].userName
        if currentUser == userName{
            cell.setMessage(data: messagesData[indexPath.row], readRC: readRecepitColor, readRI: "checkmark", ChatBBC: UIColor.green)
        }
        else{
            cell.setMessage(data: messagesData[indexPath.row], readRC: readRecepitColor, readRI: "", ChatBBC: UIColor.white)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentUser = messagesData[indexPath.row].userName
        if currentUser == userName{
            isUserEditingMessage = true
            selectedMessageTimetoken = messagesData[indexPath.row].timeToken
            print("selectedMessageTimetoken:-",selectedMessageTimetoken!)
            messageTxt.becomeFirstResponder()
        }
    }
}

extension MessagesVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.count >= 0 && string.count == 1{
            client.signal(channel: channelName,message: "is typing...") { result in
                switch result {
                case let .success(response):
                    print("Successful Response: \(response)")
                case let .failure(error):
                    print("Failed Response: \(error.localizedDescription)")
                }
            }
        } else if textField.text!.count == 1 && string.count == 0{
            client.signal(channel: channelName,message: "done typing") { result in
                switch result {
                case let .success(response):
                    print("Successful Response: \(response)")
                case let .failure(error):
                    print("Failed Response: \(error.localizedDescription)")
                }
            }
        }
        return true
    }
}

extension MessagesVC:PubNubDelegates{
    func didGetResults(result: String) {
        print(result)
    }
    
    func didGetChannelList(result: String, channelList: [String]) { }
    
    func loadingLastMessages(result: String, messages: [String : [MessageHistoryMessagesPayload]]) { }
}

extension Date {
    func toNanos() -> UInt64! {
        return UInt64(self.timeIntervalSince1970 * 10000000)
    }
}
