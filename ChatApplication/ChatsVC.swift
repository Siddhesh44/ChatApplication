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
    
    var client: PubNub!
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
        
        //        listener.didReceiveSubscription = { event in
        //            switch event {
        //            case let .presenceChanged(presence):
        //                self.userPresence = presence.presenceTimetoken
        //            default:
        //                break
        //            }
        //        }
        
        client.add(listener)
        
        client.subscribe(to: channels,withPresence: true)
        pubnubHelper.loadLastMessages(forChannels: channels,client: client)
        
        setUpNavBar()
        
        addChannelView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        //addChannelView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    @IBAction func addNewChannelBtnTapped(_ sender: UIButton) {
        
    }
    
    func setUpNavBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(ChatsVC.leaveBtnTapped))
    }
    
    @objc func leaveBtnTapped(){
        print("Leave button pressed")
        client.unsubscribeAll()
        navigationController?.popViewController(animated: true)
        
        //        addChannelView.frame = CGRect(x: 120, y: 70, width: 300, height: 300)
        //        view.addSubview(addChannelView)
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
        nextVC.client = client
        nextVC.listener = listener
        nextVC.userName = user
        nextVC.channelName = channels[indexPath.row]
        if let channelMessages = loadedMessages[channels[indexPath.row]] {
            nextVC.loadedMessages = channelMessages
        }
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
        self.loadedMessages = loadedMessages.merging(messages, uniquingKeysWith: { (first, _) in first })
        Spinner.stop()
    }
    
    func didGetResults(result: String) {
        print(result)
    }
}

