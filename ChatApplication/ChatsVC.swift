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
    var messages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNewChannelTxt.delegate = self
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        pubnubHelper.pubnubDelegate = self
        
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Chats"
        
        pubnubHelper.pubnubConfig()
        
        pubnubHelper.client.add(listener)
        
        pubnubHelper.client.subscribe(to: channels,withPresence: true)
        
        pubnubHelper.loadLastMessages(forChannels: channels)
        
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
        nextVC.listener = listener
        nextVC.messages = messages
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
        print(result)
        self.channels = channelList
    }
    
    func loadingLastMessages(result: String, messages: String) {
        print(result)
        self.messages.append(messages)
        self.chatTableView.reloadData()
    }
    
    func didGetResults(result: String) {
        print(result)
    }
    
    
}

