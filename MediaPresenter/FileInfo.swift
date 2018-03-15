//
//  FileInfo.swift
//  MediaPresenter
//
//  Created by Piotr Błachewicz on 15.03.2018.
//  Copyright © 2018 Piotr Błachewicz. All rights reserved.
//

import Foundation
import UIKit

public struct FileInfo {
    
   public var fileName: String
   public var mimeType: String
   public var url: URL?
   public var data: Data?
   public var imageData: Data?
    
   public init(withFileURL url: URL) {
        self.fileName = url.deletingPathExtension().lastPathComponent
        self.mimeType = url.mimeType()
        self.url = url
        
        if FileManager.default.fileExists(atPath: url.path) {
            let file = NSData.init(contentsOfFile: url.path)
            if (file != nil) {
                self.data = file?.copy() as! Data?
                print("File Exists")
            }
            else {
                print("There is no file")
            }
        }
    }
    
   public init(withImage image: UIImage, imageName: String) {
        self.fileName = imageName
        self.mimeType = fileName.mimeType()
        if let imageData = UIImageJPEGRepresentation(image, 1) {
            self.imageData = imageData
        }
    }
}
