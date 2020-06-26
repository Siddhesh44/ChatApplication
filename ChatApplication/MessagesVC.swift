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
    var channelName: String!
    var messages: [String] = []
    var isTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTxt.delegate = self
        
        pubnubHelper.pubnubConfig()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setNavBar()
        
        let numberOfSections = self.messageTableView.numberOfSections
        let numberOfRows = self.messageTableView.numberOfRows(inSection: numberOfSections-1)
        let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
        self.messageTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        
        
        listener!.didReceiveSubscription = { event in
            switch event {
            case let .signalReceived(signal):
                print("Signal Received from: ",signal.publisher!,"Signal",signal)
                if let userTypingActionSignal = signal.payload.stringOptional{
                    if userTypingActionSignal == "typing off"{
                        self.indicator.text = ""
                    } else{
                        if let user = signal.publisher?.stringOptional{
                            self.indicator.text = "\(user) \(userTypingActionSignal)"
                            
                            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (tTimer) in
                                self.indicator.text = ""
                            }
                            self.timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { (tTimer) in
                                if self.isTyping{
                                    self.indicator.text = "\(user) \(userTypingActionSignal)"
                                    self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (Timer) in
                                        self.indicator.text = ""
                                    }
                                }
                            }
                        }
                    }
                }
            default:
                break
            }
        }
        
        listener!.didReceiveMessage = { (message) in
            
            print("Received Message:-",message)
            
            
            let messageDate = message.timetoken.timetokenDate
            print("The message was sent at \(messageDate)")
            
            if(self.channelName == message.channel)
            {
                if let messagesFromUser = message.payload.stringOptional{
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
            case let .failure(error):
                print("Handle response error: \(error.localizedDescription)")
            }
        }
        messageTxt.text = ""
    }
    
    @IBAction func sendMessageBtn(_ sender: UIButton) {
        if(messageTxt.text == "" || messageTxt.text == nil){
            
        } else{
            self.publishMessage()
        }
    }
}

extension MessagesVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell", for: indexPath) as! MessagesTableViewCell
        cell.message.text = messages[indexPath.row]
        return cell
    }
}

extension MessagesVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pubnubHelper.client.signal(channel: channelName,message: "is typing...") { result in
            switch result {
            case let .success(response):
                print("Successful Response: \(response)")
                self.isTyping = true
            case let .failure(error):
                print("Failed Response: \(error.localizedDescription)")
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        pubnubHelper.client.signal(channel: channelName,message: "typing off") { result in
            switch result {
            case let .success(response):
                print("Successful Response: \(response)")
                self.isTyping = false
                self.timer.invalidate()
            case let .failure(error):
                print("Failed Response: \(error.localizedDescription)")
            }
        }
    }
}
