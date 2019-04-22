//
//  Utilities.swift
//  ContactTask
//
//  Created by Bharath on 19/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//
import UIKit
import Foundation

struct Utilities {
    
    static func navigatedView(bundle:String,identifier:String) -> UIViewController? {
        
        let storyBoard = UIStoryboard.init(name: bundle, bundle: nil)
        let commonViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        return commonViewController
    }
    
}
