//
//  ViewController.swift
//  ChatApplication
//
//  Created by Siddhesh jadhav on 17/06/20.
//  Copyright © 2020 infiny. All rights reserved.
//

import UIKit
import PubNub

class ViewController: UIViewController {
    
    var client: PubNub!
    var pubnubHelper = PubNubHelper()
    
    @IBOutlet weak var newUserTxt: UITextField!
    @IBOutlet weak var txt: UITextField!
    
    var userName: String?
    var newUserName: String?
    var fixedChannels: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txt.delegate = self
        newUserTxt.delegate = self
        
        pubnubHelper.pubnubDelegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    
    // MARK: Connect User
    @IBAction func btn(_ sender: UIButton) {
        userName = txt.text!
        
        var config = PubNubConfiguration(publishKey: "pub-c-f656341c-e88a-449f-9b36-aeadbbe7c364", subscribeKey: "sub-c-c2bd004c-b07d-11ea-a40b-6ab2c237bf6e")
        config.uuid = userName!
        client = PubNub(configuration: config)
        
        if userName == "Sid"{
            fixedChannels = ["new14"]
        } else if userName == "Siddhesh"{
            fixedChannels = ["new14"]
        }
        
        // pubnubHelper.fetchUsers(userName: userName!)
        txt.text = ""
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "ChatsVC") as! ChatsVC
        nextVC.user = userName
        nextVC.client = client
        if let fixedChannels = fixedChannels{
            nextVC.channels = fixedChannels
        }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    // MARK: Create User
    @IBAction func createNewUser(_ sender: UIButton) {
        newUserName = newUserTxt.text!
        print("UserName:-",newUserName!)
        //        var config = PubNubConfiguration(publishKey: "pub-c-f656341c-e88a-449f-9b36-aeadbbe7c364", subscribeKey: "sub-c-c2bd004c-b07d-11ea-a40b-6ab2c237bf6e")
        //        config.uuid = newUserName!
        //        client = PubNub(configuration: config)
        
        let newUser = UserObject(name: newUserName!, id: UUID().uuidString, externalId: "externalId", profileURL: "profileURL", email: "email", custom: ["custom": "custom"], created: Date(), updated:Date(), eTag: "eTag")
        print("userobject:-",newUser)
        
       // pubnubHelper.createUser(userName: newUser)
        newUserTxt.text = ""
        
    }
}

extension ViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: PubNubDelegates{
    func didGetChannelList(result: String, channelList: [String]) {}
    func loadingLastMessages(result: String, messages: [String: [MessageHistoryMessagesPayload]]) {}
    
    func didGetResults(result: String) {
        print(result)
    }
}
