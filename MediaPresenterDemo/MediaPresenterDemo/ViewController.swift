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
    //This contains settings and configurable
    var attachmentManager: AttachmentManager = AttachmentManager()

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Media Picker Presenter Delegate
    func didSelectFromMediaPicker(_ file: FileInfo) {
        print("Picked file: \(file.fileName)")
        //do more with file...
    }
}

