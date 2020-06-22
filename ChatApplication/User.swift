//
//  User.swift
//  ChatApplication
//
//  Created by Siddhesh jadhav on 17/06/20.
//  Copyright © 2020 infiny. All rights reserved.
//

import Foundation
import PubNub

struct User {
    
    let id: String
    var name: String
    var email: String?
    var profileURL: String?
    var externalId: String?
    var title: String?
    var created: Date
    var updated: Date
    var eTag: String
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        title: String?,
        email: String? = nil,
        profileURL: String? = nil,
        externalId: String? = nil,
        created: Date = Date(),
        updated: Date? = nil,
        eTag: String? = nil
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.email = email
        self.profileURL = profileURL
        self.externalId = externalId
        self.created = created
        self.updated = updated ?? created
        self.eTag = eTag ?? id
    }
}


// MARK: PubNubUser

extension User: PubNubUser {
    public init(from user: PubNubUser) {
        self.init(
            id: user.id,
            name: user.name,
            title: user.customValue(for: "title"),
            email: user.email,
            profileURL: user.profileURL,
            externalId: user.externalId,
            created: user.created,
            updated: user.updated,
            eTag: user.eTag
        )
    }
    
    public var custom: [String: JSONCodableScalar]? {
        guard let title = title else {
            return nil
        }
        return ["title": title]
    }
}
