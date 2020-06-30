//
//  ChatsVC.swift
//  ChatApplication
//
//  Created by Siddhesh jadhav on 17/06/20.
//  Copyright © 2020 infiny. All rights reserved.
//

import UIKit
import PubNub

class ChatsVC: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet var addChannelView: UIView!
    @IBOutlet weak var addNewChannelTxt: UITextField!
    
    var pubnubHelper = PubNubHelper()
    var user: String?
    let listener = SubscriptionListener(queue: .main)
    var channels: [String] = []
    var loadedMessages: [String: [MessageHistoryMessagesPayload]] = [:]
    var userPresence: Timetoken?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNewChannelTxt.delegate = self
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        pubnubHelper.pubnubDelegate = self
        
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Chats"
        
        pubnubHelper.pubnubConfig()
        
        listener.didReceiveSubscription = { event in
            switch event {
            case let .presenceChanged(presence):
                self.userPresence = presence.presenceTimetoken
            default:
                break
            }
        }
        
        pubnubHelper.client.add(listener)
        
        pubnubHelper.client.subscribe(to: channels,withPresence: true)
        
        pubnubHelper.loadLastMessages(forChannels: channels)
        Spinner.start()
        
        setUpNavBar()
        
        addChannelView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        addChannelView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    @IBAction func addNewChannelBtnTapped(_ sender: UIButton) {
        
    }
    
    func setUpNavBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-add-64"), style: .plain, target: self, action: #selector(ChatsVC.addChannelBtnTapped))
    }
    
    @objc func addChannelBtnTapped(){
        print("add channel button pressed")
        addChannelView.frame = CGRect(x: 120, y: 70, width: 300, height: 300)
        view.addSubview(addChannelView)
    }
}

extension ChatsVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatsTableViewCell
        cell.textLabel?.text = channels[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC") as! MessagesVC
        var channelName: String = ""
        channelName = channels[indexPath.row]
        nextVC.listener = listener
        if let channelMessages = loadedMessages[channelName]{
            var mcoll: [String] = []
            var timeToken: [String] = []
            var messageTimeToken: [Timetoken] = []

            for m in channelMessages{
                mcoll.append(m.message.stringOptional!)
                let date = m.timetoken.timetokenDate
                messageTimeToken.append(m.timetoken)
                print("&&&&&&&&&&&&&&",messageTimeToken)
                let localDate = pubnubHelper.pubNubDateFormatter(date: date)
                timeToken.append(localDate)
            }
            //nj
            nextVC.messages = mcoll
            nextVC.timeToken = timeToken
            nextVC.userPresence = userPresence
            nextVC.messageTimeToken = messageTimeToken
        }
        nextVC.userName = user
        nextVC.channelName = channels[indexPath.row]
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension ChatsVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ChatsVC: PubNubDelegates{
    func didGetChannelList(result: String, channelList: [String]) {
        print("didGetChannelList",result)
        self.channels = channelList
    }
    
    func loadingLastMessages(result: String, messages: [String: [MessageHistoryMessagesPayload]]) {
        print("loadingLastMessages",result)
        print("History:-",messages)
        
        self.loadedMessages = loadedMessages.merging(messages, uniquingKeysWith: { (first, _) in first })
        Spinner.stop()
        
    }
    func didGetResults(result: String) {
        print(result)
    }
}

