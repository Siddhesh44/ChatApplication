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
    
    @IBOutlet weak var newUserTxt: UITextField!
    @IBOutlet weak var txt: UITextField!
    
    var userName: String?
    var newUserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txt.delegate = self
        newUserTxt.delegate = self
        
        var config = PubNubConfiguration(publishKey: "pub-c-f656341c-e88a-449f-9b36-aeadbbe7c364", subscribeKey: "sub-c-c2bd004c-b07d-11ea-a40b-6ab2c237bf6e")
        config.authKey = "sec-c-NzM3MWM5MWEtZTEwNy00ZDQ2LWE1YTQtMmZlNWUxZmU1MTFi"
        client = PubNub(configuration: config)
        
//        client.add(channels: ["Group1", "Friend1"],to: "Sid") { result in
//            switch result {
//            case let .success(response):
//                print("################")
//                print("Successful Add Channels Sid: \(response)")
//            case let .failure(error):
//                print("###############")
//                print("Failed Add Channels to Sid: \(error.localizedDescription)")
//            }
//        }
//
//        client.add(channels: ["Group1", "Friend2"],to: "Siddhesh") { result in
//            switch result {
//            case let .success(response):
//                print("#################")
//                print("Successful Add Channels To Siddhesh: \(response)")
//            case let .failure(error):
//                print("###############")
//                print("Failed Add Channels To Siddhesh: \(error.localizedDescription)")
//            }
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func btn(_ sender: UIButton) {
        userName = txt.text!
        
        client.fetch(userID: userName!) { (result) in
            print("user fetched",result)
        }
        
        client.listChannels(for: userName!) { result in
            switch result {
            case let .success(response):
                print("###############")
                print("Successful List of Channels in Group Response: \(response)")
            case let .failure(error):
                print("###############")
                print("Failed Add Channels Response: \(error.localizedDescription)")
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "ChatsVC") as! ChatsVC
        nextVC.client = client
        nextVC.user = userName
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func createNewUser(_ sender: UIButton) {
        newUserName = newUserTxt.text!
        print(newUserName!)
        let newUser = UserObject(name: newUserName!, id: UUID().uuidString, externalId: "externalId", profileURL: "profileURL", email: "email", custom: ["custom": "custom"], created: Date(), updated:Date(), eTag: "eTag")
        
        print("###############")
        print("userobject",newUser)
        
        client.create(user: newUser) { (result) in
            print("###############")
            print("new User creating:-",result)
            switch result{
            case .success(let response):
                print("###############")
                print("response after creating user:-",response)
            case .failure(let error):
                print("###############")
                print("Error occurred:-",error.localizedDescription)
            }
        }
    }
}

extension ViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
