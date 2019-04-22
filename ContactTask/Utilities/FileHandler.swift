//
//  FileHandler.swift
//  ContactTask
//
//  Created by Bharath on 18/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import UIKit

class FilePathHandler: NSObject {
    static var newFolderName: String!
    class func createFolder(newFolder: String){
        self.newFolderName = newFolder
        let fileManager = FileManager.default
        
        do {
            if !(fileManager.fileExists(atPath: self.folderPath as String)) {
                let _ = try fileManager.createDirectory(atPath: self.folderPath as String, withIntermediateDirectories: true, attributes: nil)
            }
        } catch { }
    }
    
    class func getFileLocalPath(fileName: String) -> String{
        let newfilePath = (self.folderPath as NSString).appendingPathComponent("\(fileName)") as String
        return newfilePath
    }
    
    class var dirPath: String {
        return (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
    }
    
    class var folderPath: String {
        return (self.dirPath as NSString).appendingPathComponent("\(self.newFolderName!)")
    }
    
    class func fileExistsWith(name: String) -> Bool {
        return FileManager.default.fileExists(atPath: self.getFileLocalPath(fileName: name))
    }
}

