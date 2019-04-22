//
//  NetworkHandler.swift
//  ContactTask
//
//  Created by Bharath on 18/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import UIKit
import Foundation

enum HttpMethod: String {
    case GET = "GET",POST = "POST",PUT = "PUT"
}

class NetworkHandler {
    
    static var session : URLSession!
    
    typealias success = (Data) -> Void
    typealias failure = (Error) -> Void

   static func makeRequest(urlString: String, parameter: [String: Any]?, httpMethod: HttpMethod, success: @escaping success, failure: @escaping failure) {
        
        
        let sessionConfiguaration : URLSessionConfiguration  = URLSessionConfiguration.ephemeral
        
        session = URLSession.init(configuration: sessionConfiguaration, delegate:nil, delegateQueue: nil)
        
        let request : NSMutableURLRequest = NSMutableURLRequest.init(url: URL(string: urlString)! , cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0)
        
        request.httpMethod = httpMethod.rawValue
        
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        func addData() {
            do {
                if let parameters = parameter {
                    let postData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                    request.httpBody = postData

                }
            }
            catch {
                debugPrint(error.localizedDescription)
            }
        }
        
        switch httpMethod {
            case .GET: break
            case .POST: addData()
            case .PUT: addData()
        }
        
        let downloadTask = session.downloadTask(with: request as URLRequest) { (location, response, error) in
            
            do {
                
                if error != nil {
                    if let error = error {
                        failure(error)
                    }
                    return
                }
                if let locationUrl = location {
                    let responsedata = try Data.init(contentsOf: locationUrl)
                    success(responsedata)
                } else {
                    if let error = error {
                        failure(error)
                    }
                }

            } catch {
                
            }
        }
        downloadTask.resume()
    }
}
