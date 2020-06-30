//
//  PubNubHelper.swift
//  ChatApplication
//
//  Created by Siddhesh jadhav on 23/06/20.
//  Copyright © 2020 infiny. All rights reserved.
//

import Foundation
import PubNub

protocol PubNubDelegates: class{
    func didGetResults(result: String)
    func didGetChannelList(result: String,channelList: [String])
    func loadingLastMessages(result:String,messages: [String: [MessageHistoryMessagesPayload]])
}

class PubNubHelper {
    
    var client: PubNub!
    weak var pubnubDelegate: PubNubDelegates?
    var messageDic: [String: [MessageHistoryMessagesPayload]]?
    var messageDetails: [MessageHistoryMessagesPayload] = []
    func pubnubConfig() {
        var config = PubNubConfiguration(publishKey: "pub-c-f656341c-e88a-449f-9b36-aeadbbe7c364", subscribeKey: "sub-c-c2bd004c-b07d-11ea-a40b-6ab2c237bf6e")
        // config.authKey = "sec-c-NzM3MWM5MWEtZTEwNy00ZDQ2LWE1YTQtMmZlNWUxZmU1MTFi"
        //        config.uuid = UUID().uuidString
        //        print("##################",config.uuid)
        client = PubNub(configuration: config)
    }
    
    func createUser(userName: PubNubUser) {
        client.create(user: userName) { (result) in
            switch result{
            case .success(let response):
                self.pubnubDelegate?.didGetResults(result: "Response after creating user:-\(response)")
            case .failure(let error):
                self.pubnubDelegate?.didGetResults(result: "Error occurred while creating user:-\(error.localizedDescription)")
            }
        }
    }
    
    func fetchUsers(userName: String){
        client.fetch(userID: userName) { (result) in
            switch result{
            case let .success(response):
                self.pubnubDelegate?.didGetResults(result: "Response after fetching user:-\(response)")
                self.channelList(userName: "User")
            case let .failure(error):
                self.pubnubDelegate?.didGetResults(result: "Error occurred while fetching user:-\(error.localizedDescription)")
            }
        }
    }
    
    func addChannels(){
        client.add(channels: ["Group1", "Friend1"],to: "Sid") { result in
            switch result {
            case let .success(response):
                print("Successful Add Channels Sid: \(response)")
            case let .failure(error):
                self.pubnubDelegate?.didGetResults(result: "Error occurred while Adding Channels:-\(error.localizedDescription)")
            }
        }
        
        client.add(channels: ["Group1", "Friend2"],to: "Siddhesh") { result in
            switch result {
            case let .success(response):
                print("Successful Add Channels To Siddhesh: \(response)")
            case let .failure(error):
                self.pubnubDelegate?.didGetResults(result: "Error occurred while Adding Channels:-\(error.localizedDescription)")
            }
        }
    }
    
    func channelList(userName: String){
        client.listChannels(for: userName) { result in
            switch result {
            case let .success(response):
                self.pubnubDelegate?.didGetChannelList(result: "Success at getting channels:-\(response)", channelList: ["Channel1","Channel2"])
            case let .failure(error):
                self.pubnubDelegate?.didGetResults(result: "Error occurred while listing channel:-\(error.localizedDescription)")
            }
        }
    }
    
    func loadLastMessages(forChannels: [String])
    {
        client.fetchMessageHistory(for: forChannels, max: 25, start: nil, end: nil) { (result) in
            print("Loaded History:-",result)
            switch result{
            case let .success(response):
                for c in forChannels{
                    if let response = response[c]?.messages {
                        self.messageDetails = []
                        for m in response{
                            
                            self.messageDetails.append(m)
                        }
                    }
                    self.messageDic = [c:self.messageDetails]
                    self.pubnubDelegate?.loadingLastMessages(result: "Success at Loading Messages", messages: self.messageDic!)
                }
            case let .failure(error):
                self.pubnubDelegate?.didGetResults(result: "Error occurred while loading history:-\(error.localizedDescription)")
            }
        }
    }
    
    func pubNubDateFormatter(date: Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = .current
        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
}