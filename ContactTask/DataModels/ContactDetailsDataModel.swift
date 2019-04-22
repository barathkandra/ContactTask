//
//  ContactDetailsDataModel.swift
//  ContactTask
//
//  Created by Bharath on 19/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import Foundation

struct ContactDetails: Codable {
    let id: Int?
    var firstName, lastName, email, phoneNumber: String?
    var profilePic: String?
    let favorite: Bool?
    let createdAt, updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phoneNumber = "phone_number"
        case profilePic = "profile_pic"
        case favorite
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
