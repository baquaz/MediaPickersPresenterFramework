//
//  AttachementHandler.swift
//  MediaPresenter
//
//  Created by Piotr Błachewicz on 14.03.2018.
//  Copyright © 2018 Piotr Błachewicz. All rights reserved.
//

import UIKit
import Photos

//MARK: - Strings
fileprivate struct Constants {
    static let actionSheetTitle = "Add a File"
    static let actionSheetMessage = "Choose a filetype to add..."
    static let camera = "Camera"
    static let phoneLibrary = "Phone Library"
    static let video = "Video"
    static let file = "File"
    
    static let settingsBtnTitle = "Settings"
    static let cancelTitle = "Cancel"
    
    static let alertForPhotoLibraryMessage = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."
    static let alertForCameraAccessMessage = "App does not have access to your camera. To enable access, tap settings and turn on Camera."
    static let alertForVideoLibraryMessage = "App does not have access to your video. To enable access, tap settings and turn on Video Library Access."
}

public enum AttachmentType: String{
    case camera, photoLibrary, documents, video
}

//MARK: - Attachment Manager
public struct AttachmentManager {
    public init() {}
    
    // Customization of pickers controllers
    public struct Settings {
        public var cameraAllowsEditing: Bool = false
        public var libraryAllowsEditing: Bool = false
        public var documentTypes: [String] = ["public.image", "public.data", "public.content"]
        public var allowedAttachments: [AttachmentType] = [.camera, .photoLibrary, .documents, .video]
    }
    
    public var settings = Settings()
    public var actionSheet = UIAlertController()
    public var imageHandler: ImagePickerHandler?
    public var documentHandler: DocumentPickerHandler?
    
    fileprivate mutating func prepareImagePicker(for type: AttachmentType) {
        switch type {
        case .camera:
            imageHandler = ImagePickerHandler(sourceType: .camera, allowsEditing: settings.cameraAllowsEditing)
        case .photoLibrary:
            imageHandler = ImagePickerHandler(sourceType: .photoLibrary, allowsEditing: settings.libraryAllowsEditing)
        default:break
        }
    }
    
    fileprivate mutating func prepareDocumentPicker() {
        let picker = UIDocumentPickerViewController(documentTypes: settings.documentTypes, in: .import)
        documentHandler = DocumentPickerHandler(picker: picker)
    }
}

//MARK: - Protocols
public protocol UIPresentable: class {
    var viewController: UIViewController { get }
}

extension UIPresentable where Self: UIViewController {
    public var viewController: UIViewController {
        return self
    }
}
//MARK: - MediaPickerPresenter Protocol
public protocol MediaPickerPresenter: UIPresentable {
    var attachmentManager: AttachmentManager { get set }
    func presentAttachmentActionSheet()
    func didSelectFromMediaPicker(_ file: FileInfo)
}

//MARK: Implementation
public extension MediaPickerPresenter {
    //MARK: Menu
    public func presentAttachmentActionSheet() {
        attachmentManager.actionSheet = UIAlertController(title: Constants.actionSheetTitle, message: Constants.actionSheetMessage, preferredStyle: .actionSheet)
        
        let allowedAttachments = attachmentManager.settings.allowedAttachments
        
        for attachment in allowedAttachments {
            switch attachment {
            case .camera:
                attachmentManager.actionSheet.addAction(UIAlertAction(title: Constants.camera, style: .default, handler: { (action) in
                    self.checkAuthorizationStatus(attachmentType: .camera)
                }))
            case .photoLibrary:
                attachmentManager.actionSheet.addAction(UIAlertAction(title: Constants.phoneLibrary, style: .default, handler: { (action) in
                    self.checkAuthorizationStatus(attachmentType: .photoLibrary)
                }))
            case .documents:
                attachmentManager.actionSheet.addAction(UIAlertAction(title: Constants.file, style: .default, handler: { (action) in
                    self.openDocuments()
                }))
            case .video:
                attachmentManager.actionSheet.addAction(UIAlertAction(title: Constants.video, style: .default, handler: { (action) in
                    self.openVideo()
                }))
            }
        }
        attachmentManager.actionSheet.addAction(UIAlertAction(title: Constants.cancelTitle, style: .cancel, handler: nil))
        viewController.present(attachmentManager.actionSheet, animated: true, completion: nil)
    }
    
    //MARK: Open Controllers
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            attachmentManager.prepareImagePicker(for: .camera)
            attachmentManager.imageHandler?.delegate = self
            viewController.present((attachmentManager.imageHandler?.picker)!, animated: true, completion: nil)
        }
    }
    
    private func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            attachmentManager.prepareImagePicker(for: .photoLibrary)
            attachmentManager.imageHandler?.delegate = self
            viewController.present((attachmentManager.imageHandler?.picker)!, animated: true, completion: nil)
        }
    }
    
    private func openDocuments() {
        attachmentManager.prepareDocumentPicker()
        attachmentManager.documentHandler?.delegate = self
        viewController.present((attachmentManager.documentHandler?.picker)!, animated: true, completion: nil)
    }
    
    private func openVideo() {
        //MARK: <#TODO: - open video#>
    }
    
    //MARK: Authorization
    private func checkAuthorizationStatus(attachmentType: AttachmentType) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            if attachmentType == .camera {
                openCamera()
            }
            else if attachmentType == .photoLibrary {
                openPhotoLibrary()
            }
        case .denied:
            showAlertForSettings(attachmentType)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    if attachmentType == .camera {
                        self.openCamera()
                    }
                    else if attachmentType == .photoLibrary {
                        self.openPhotoLibrary()
                    }
                } else {
                    self.showAlertForSettings(attachmentType)
                }
            })
        case .restricted:
            showAlertForSettings(attachmentType)
        }
    }
    
    //MARK: Settings Alert
    private func showAlertForSettings(_ attachmentType: AttachmentType){
        var alertTitle: String = ""
        if attachmentType == .camera{
            alertTitle = Constants.alertForCameraAccessMessage
        }
        if attachmentType == .photoLibrary{
            alertTitle = Constants.alertForPhotoLibraryMessage
        }
        if attachmentType == .video{
            alertTitle = Constants.alertForVideoLibraryMessage
        }
        
        let cameraUnavailableAlertController = UIAlertController (title: alertTitle , message: nil, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: Constants.settingsBtnTitle, style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: Constants.cancelTitle, style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(cancelAction)
        cameraUnavailableAlertController .addAction(settingsAction)
        viewController.present(cameraUnavailableAlertController , animated: true, completion: nil)
    }
}
