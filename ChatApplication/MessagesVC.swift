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
    var typingIndicator = UILabel()
    
    
    var listener: SubscriptionListener?
    var client: PubNub!
    var channelName: String?
    var messages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTxt.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setNavBar()
        
        listener!.didReceiveSubscription = { event in
            switch event {
            case let .signalReceived(signal):
                print("Signal Received from: ",signal.publisher!,"Signal",signal)
                if let userTypingActionSignal = signal.payload.stringOptional{
                    if let user = signal.publisher?.stringOptional{
                        print(user,"is",userTypingActionSignal)
                        self.typingIndicator.text = userTypingActionSignal
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
        typingIndicator.frame = CGRect(x: 0, y: 20, width: 300, height: 21)
        typingIndicator.text = "User is Typing..."
        typingIndicator.font = UIFont.systemFont(ofSize: 10)
        topView.addSubview(channelNameLbl)
        topView.addSubview(typingIndicator)
        navigationItem.titleView = topView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-menu-vertical-50"), style: .plain, target: self, action: #selector(MessagesVC.menuBtnTapped))
    }
    
    @objc func menuBtnTapped(){
        print("Menu  button pressed")
    }
    
    func publishMessage() {
        if(messageTxt.text != "" || messageTxt.text != nil){
            let messageString: String = messageTxt.text!
            print("message publiing")
            client.publish(channel: channelName!, message: messageString) { (status) in
                switch status {
                case let .success(response):
                    print("Handle successful Publish response: \(response)")
                case let .failure(error):
                    print("Handle response error: \(error.localizedDescription)")
                }
            }
            messageTxt.text = ""
        }
    }
    
    @IBAction func sendMessageBtn(_ sender: UIButton) {
        publishMessage()
    }
}

extension MessagesVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell", for: indexPath) as! MessagesTableViewCell
        return cell
    }
}

extension MessagesVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        client.signal(channel: channelName!,message: "is typing...") { result in
            switch result {
            case let .success(response):
                print("Successful Response: \(response)")
            case let .failure(error):
                print("Failed Response: \(error.localizedDescription)")
            }
        }
    }
}