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
    
    var client: PubNub!
    var user: String?
    let listener = SubscriptionListener(queue: .main)
    var channels: [String] = []
    var messages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Chats"
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        client.add(listener)
        channels = ["Group1","Group2","Friend1"]
        client.subscribe(to: channels,withPresence: true)
        
        loadLastMessages()
        
        setUpNavBar()
    }
    
    func setUpNavBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-add-64"), style: .plain, target: self, action: #selector(ChatsVC.addChannelBtnTapped))
    }

    @objc func addChannelBtnTapped(){
        print("add channel button pressed")
    }
    
    func loadLastMessages()
    {
        client.fetchMessageHistory(for: channels, max: 25, start: nil, end: nil) { (result) in
            switch result{
            case let .success(response):
                print("######################")
                print("Successful History Fetch Response: \(response)")
                print("######################")
                
                if let response = response["My"]?.messages{
                    for m in response{
                        if let oldMessages = m.message.stringOptional {
                            print("messages",oldMessages)
                            self.messages.append(oldMessages)
                        }
                    }
                }
                
                self.chatTableView.reloadData()
                
            case let .failure(error):
                print("######################")
                print("Failed History Fetch Response: \(error.localizedDescription)")
                print("######################")
            }
        }
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
        nextVC.client = client
        nextVC.messages = messages
        nextVC.channelName = channels[indexPath.row]
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

