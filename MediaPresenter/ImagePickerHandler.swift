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

    var delegate: MediaPickerPresenter?
    var picker = UIImagePickerController()
    
    init(sourceType: UIImagePickerController.SourceType, allowsEditing: Bool) {
        picker.allowsEditing = allowsEditing
        picker.sourceType = sourceType
        super.init()
        self.picker.delegate = self
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker cancelled")
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let imageTypeInfo: String
        if picker.allowsEditing {
            imageTypeInfo = convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)
        } else {
            imageTypeInfo = convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)
        }
        
        if let image = info[imageTypeInfo] as? UIImage {
            var fileName = "file.jpg"
            
            if let asset = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.phAsset)] as? PHAsset {
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
