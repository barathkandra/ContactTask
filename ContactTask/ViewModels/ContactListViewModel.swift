//
//  ContactListViewModel.swift
//  ContactTask
//
//  Created by Bharath on 18/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import UIKit

class ContactListViewModel: NSObject {

    var contactDictionary = [String: [ContactListElement]]()
    var contactSectionTitles = [String]()
    var contactArray:[ContactListElement] = []
    
    
    typealias response = (Error?) -> Void

    func callingGetContactService(completion: @escaping response) {
        
        let urlString = BASE_URL + "contacts"
        
        NetworkHandler.makeRequest(urlString: urlString, parameter: nil, httpMethod: .GET, success: { (data) in
            do {
                let contacts = try JSONDecoder().decode([ContactListElement].self, from: data)
                self.contactArray = contacts.sorted(by: { (firstObj,secondObj) -> Bool in
                    let first = firstObj.firstName ?? ""
                    let second = secondObj.firstName ?? ""
                    return (first.localizedCaseInsensitiveCompare(second) == .orderedAscending)
                })
                self.contactDetailsArray()
                completion(nil)
            } catch {
                Toast.shared().showToast(withDuration: 3, afterDelay: 0.5, withMessage: error.localizedDescription, toastType: .error, hideToastAfterCompletion: true)
                completion(error)
            }
        }) { (error) in
            Toast.shared().showToast(withDuration: 3, afterDelay: 0.5, withMessage: error.localizedDescription, toastType: .error, hideToastAfterCompletion: true)

            completion(error)
        }
        
    }
    
    func contactDetailsArray() {
        contactDictionary.removeAll()
        
        for contacts in self.contactArray {
            if let firstName = contacts.firstName {
                let contactKeys = String(firstName.prefix(1)).uppercased()
                if var contactValues = contactDictionary[contactKeys] {
                    contactValues.append(contacts)
                    contactDictionary[contactKeys] = contactValues
                } else {
                    contactDictionary[contactKeys] = [contacts]
                }

            }
        }
        contactSectionTitles = [String](contactDictionary.keys)
        contactSectionTitles = contactSectionTitles.sorted(by: { $0 < $1 })
    }
}
