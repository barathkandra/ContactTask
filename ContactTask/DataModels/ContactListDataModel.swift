//
//  ContactListDataModel.swift
//  ContactTask
//
//  Created by Bharath on 18/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import Foundation

typealias ContactList = [ContactListElement]

struct ContactListElement: Codable {
    let id: Int?
    let firstName, lastName: String?
    let profilePic: String?
    let favorite: Bool?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case profilePic = "profile_pic"
        case favorite
        case url
    }
}
