//
//  ImagePicker.swift
//  MediaPresenter
//
//  Created by Piotr Błachewicz on 14.03.2018.
//  Copyright © 2018 Piotr Błachewicz. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

public class ImagePickerHandler: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    enum ImageType: String {
        case Original
        case Edited
    }
    
    var currentVC: UIViewController?
    var delegate: MediaPickerPresenter?
    var picker = UIImagePickerController()
    
    init(sourceType: UIImagePickerControllerSourceType, allowsEditing: Bool) {
        picker.allowsEditing = allowsEditing
        picker.sourceType = sourceType
        super.init()
        self.picker.delegate = self
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker cancelled")
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageTypeInfo: String
        if picker.allowsEditing {
            imageTypeInfo = UIImagePickerControllerEditedImage
        } else {
            imageTypeInfo = UIImagePickerControllerOriginalImage
        }
        
        if let image = info[imageTypeInfo] as? UIImage {
            var fileName = "file.jpg"
            
            if let asset = info[UIImagePickerControllerPHAsset] as? PHAsset {
                if let assetFileName = (asset.value(forKey: "filename")) as? String {
                    fileName = assetFileName
                }
            }
            
            let file = FileInfo(withImage: image, imageName: fileName)
            self.delegate?.didSelectFromMediaPicker(file)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
