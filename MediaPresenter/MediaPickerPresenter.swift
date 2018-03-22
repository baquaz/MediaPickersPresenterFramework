//
//  AttachementHandler.swift
//  MediaPresenter
//
//  Usage:
//    0. Add Privacy Usage Description for camera and phone libraries into Info.plist - Important!
//    1. Subclass MediaPickerPresenter and conform to protocol
//    2. (Optional) Customize settings for AttachmentManager settings
//    3. Open menu - presentAttachmentActionSheet()
//    4. Check result in delegate - didSelectFromMediaPicker(_ file: FileInfo)
//
//  Created by Piotr Błachewicz on 14.03.2018.
//  Copyright © 2018 Piotr Błachewicz. All rights reserved.
//

import UIKit
import Photos

public enum AttachmentType: String{
    case camera, photoLibrary, documents, video
}

//MARK: - Attachment Manager
public struct AttachmentManager {
    public init() {}
    
    // MARK: Settings
    public struct Settings {
        //MARK: Titles
        public struct LabelTitles {
            public var actionSheetTitle: String = "Add a File"
            public var actionSheetSubtitle: String = "Choose a type..."
            public var camera: String = "Camera"
            public var phoneLibrary: String = "Phone Library"
            public var video: String = "Video"
            public var file: String = "File"
            
            public var settingsBtnTitle: String = "Settings"
            public var cancelTitle: String = "Cancel"
            
            public var alertForPhotoLibraryMessage: String = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."
            public var alertForCameraAccessMessage: String = "App does not have access to your camera. To enable access, tap settings and turn on Camera."
            public var alertForVideoLibraryMessage: String = "App does not have access to your video. To enable access, tap settings and turn on Video Library Access."
        }
        
        public var titles: LabelTitles = LabelTitles()
        
        //MARK: Picker Options
        public var cameraAllowsEditing: Bool = false
        public var libraryAllowsEditing: Bool = false
        public var documentTypes: [String] = ["public.image", "public.data", "public.content"]
        public var allowedAttachments: [AttachmentType] = [.camera, .photoLibrary, .documents, .video]
    }
    
    public var settings = Settings()
    
    //MARK: Controllers
    fileprivate lazy var actionSheet = UIAlertController()
    fileprivate var imageHandler: ImagePickerHandler?
    fileprivate var documentHandler: DocumentPickerHandler?
    
    //MARK: Setup
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
        let titles = attachmentManager.settings.titles
        let allowedAttachments = attachmentManager.settings.allowedAttachments
        
        attachmentManager.actionSheet = UIAlertController(title: titles.actionSheetTitle, message: titles.actionSheetSubtitle, preferredStyle: .actionSheet)
        
        for attachment in allowedAttachments {
            switch attachment {
            case .camera:
                attachmentManager.actionSheet.addAction(UIAlertAction(title: titles.camera, style: .default, handler: { (action) in
                    self.checkAuthorizationStatus(attachmentType: .camera)
                }))
            case .photoLibrary:
                attachmentManager.actionSheet.addAction(UIAlertAction(title: titles.phoneLibrary, style: .default, handler: { (action) in
                    self.checkAuthorizationStatus(attachmentType: .photoLibrary)
                }))
            case .documents:
                attachmentManager.actionSheet.addAction(UIAlertAction(title: titles.file, style: .default, handler: { (action) in
                    self.openDocuments()
                }))
            case .video:
                attachmentManager.actionSheet.addAction(UIAlertAction(title: titles.video, style: .default, handler: { (action) in
                    self.openVideo()
                }))
            }
        }
        attachmentManager.actionSheet.addAction(UIAlertAction(title: titles.cancelTitle, style: .cancel, handler: nil))
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
        let titles = attachmentManager.settings.titles
        var alertTitle: String = ""
        if attachmentType == .camera{
            alertTitle = titles.alertForCameraAccessMessage
        }
        if attachmentType == .photoLibrary{
            alertTitle = titles.alertForPhotoLibraryMessage
        }
        if attachmentType == .video{
            alertTitle = titles.alertForVideoLibraryMessage
        }
        
        let cameraUnavailableAlertController = UIAlertController (title: alertTitle , message: nil, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: titles.settingsBtnTitle, style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: titles.cancelTitle, style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(cancelAction)
        cameraUnavailableAlertController .addAction(settingsAction)
        viewController.present(cameraUnavailableAlertController , animated: true, completion: nil)
    }
}
