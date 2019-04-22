//
//  ContactDetailsViewModel.swift
//  ContactTask
//
//  Created by Bharath on 18/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import UIKit

class ContactDetailsViewModel: NSObject {
    
    var contactDetails: ContactDetails?
    
    typealias response = (Error?) -> Void
    
    func getContactDetailsFromService(_ id:Int,_ completion: @escaping response) {
        
        let urlString = BASE_URL + "contacts/" + id.description
        
        NetworkHandler.makeRequest(urlString: urlString, parameter: nil, httpMethod: .GET, success: { (data) in
            do {
                self.contactDetails = try JSONDecoder().decode(ContactDetails.self, from: data)
                completion(nil)
            } catch {
                completion(error)
            }
        }) { (error) in
            completion(error)
        }
        
    }
    
    func callingAddOrUpdateDetailsService(_ id:Int, _ fav: Bool = false, isNew:Bool = false,_ completion: @escaping response) {
        
        var urlString = BASE_URL + "contacts"
        
        urlString =  isNew ? urlString : (urlString + "/" + id.description)
        
        var favoriteDict = [String: Any]()
        favoriteDict["first_name"] = contactDetails?.firstName
        favoriteDict["last_name"] = contactDetails?.lastName
        favoriteDict["email"] = contactDetails?.email
        favoriteDict["profile_pic"] = contactDetails?.profilePic
        favoriteDict["phone_number"] = contactDetails?.phoneNumber
        favoriteDict["favorite"] = fav
        
        if isNew {
            favoriteDict["created_at"] = Date().string(with: "yyyy-MM-dd'T'HH:mm:ssZ")
        } else {
            favoriteDict["created_at"] = contactDetails?.createdAt
        }
        
        favoriteDict["updated_at"] = Date().string(with: "yyyy-MM-dd'T'HH:mm:ssZ")
        
        
        NetworkHandler.makeRequest(urlString: urlString, parameter: favoriteDict, httpMethod: (isNew ? .POST : .PUT), success: { (data) in
            
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                
                if let errors = response?["errors"] as? [String], !errors.isEmpty {
                    DispatchQueue.main.async {
                        Toast.shared().showToast(withDuration: 3, afterDelay: 0, withMessage: errors.first ?? "", toastType: .error, hideToastAfterCompletion: true)
                        let errorTemp = NSError(domain:"", code: 400, userInfo:nil)
                        completion(errorTemp)
                    }
                    return
                }
                
                self.contactDetails = try JSONDecoder().decode(ContactDetails.self, from: data)
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
    
}

