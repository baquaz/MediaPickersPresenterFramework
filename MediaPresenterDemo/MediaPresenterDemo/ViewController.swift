//
//  ViewController.swift
//  MediaPresenterDemo
//
//  Created by Piotr Błachewicz on 15.03.2018.
//  Copyright © 2018 Piotr Błachewicz. All rights reserved.
//

import UIKit
import MediaPresenter

class ViewController: UIViewController, MediaPickerPresenter {
    //MARK: Media Pickers Manager
    //This contains settings and configuration
    var attachmentManager: AttachmentManager = AttachmentManager()

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var titles = attachmentManager.settings.titles
        titles.actionSheetTitle = "My title"
        titles.cancelTitle = "CANCEL"
        
        var settings = attachmentManager.settings
        settings.allowedAttachments = [.photoLibrary, .documents];
        settings.documentTypes = ["public.image", "public.data"];
        settings.libraryAllowsEditing = true
        settings.cameraAllowsEditing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addFileTap(_ sender: Any) {
        presentAttachmentActionSheet()
    }
    
    //MARK: - Media Picker Presenter Delegate
    func didSelectFromMediaPicker(_ file: FileInfo) {
        print("Picked file: \(file.fileName)")
        //do more with file...
    }
}

