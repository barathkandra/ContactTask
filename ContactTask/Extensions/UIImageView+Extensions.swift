//
//  UIImageView+Extensions.swift
//  ContactTask
//
//  Created by Bharath on 18/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func downloadImage(url: String, downloadComplete: (() -> ())?) {
        let fileManager = FileManager.default
        let filePath = FilePathHandler.getFileLocalPath(fileName: (url as NSString).lastPathComponent)
        if fileManager.fileExists(atPath: filePath), let image = UIImage(contentsOfFile: filePath) {
            DispatchQueue.main.async {
                self.image = image
                if let completion = downloadComplete {
                    completion()
                }
            }
            return
        }
        if let Url = URL.init(string: url) {
            getDataFromUrl(url: Url) { data, response, error in
                guard let data = data, error == nil
                    else {
                        if let completion = downloadComplete {
                            completion()
                        }
                        return
                }
                DispatchQueue.main.async() {
                    if let image = UIImage(data: data) {
                        if !(fileManager.fileExists(atPath: filePath)) {
                            if let imageData = image.pngData() {
                                _ = fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
                            } else if let imageData = image.jpegData(compressionQuality: 0.5) {
                                _ = fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
                            }
                        }
                        if self.image != image{
                            DispatchQueue.main.async {
                                self.image = image
                                if let completion = downloadComplete {
                                    completion()
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}
