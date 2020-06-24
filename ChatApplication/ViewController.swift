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
    
    var pubnubHelper = PubNubHelper()
    
    @IBOutlet weak var newUserTxt: UITextField!
    @IBOutlet weak var txt: UITextField!
    
    var userName: String?
    var newUserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txt.delegate = self
        newUserTxt.delegate = self
        
        pubnubHelper.pubnubDelegate = self
        
        pubnubHelper.pubnubConfig()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    
    // MARK: Connect User
    @IBAction func btn(_ sender: UIButton) {
        userName = txt.text!
        
        pubnubHelper.fetchUsers(userName: userName!)
        txt.text = ""
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "ChatsVC") as! ChatsVC
        nextVC.user = userName
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    // MARK: Create User
    @IBAction func createNewUser(_ sender: UIButton) {
        newUserName = newUserTxt.text!
        print("UserName:-",newUserName!)
        
        let newUser = UserObject(name: newUserName!, id: UUID().uuidString, externalId: "externalId", profileURL: "profileURL", email: "email", custom: ["custom": "custom"], created: Date(), updated:Date(), eTag: "eTag")
        print("userobject:-",newUser)
        
        pubnubHelper.createUser(userName: newUser)
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
    func loadingLastMessages(result: String, messages: String) {}
    
    func didGetResults(result: String) {
        print(result)
    }
}
