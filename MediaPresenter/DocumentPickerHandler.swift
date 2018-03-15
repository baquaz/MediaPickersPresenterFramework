//
//  DocumentPickerHandler.swift
//  MediaPresenter
//
//  Created by Piotr Błachewicz on 15.03.2018.
//  Copyright © 2018 Piotr Błachewicz. All rights reserved.
//

import UIKit

public class DocumentPickerHandler: NSObject, UIDocumentPickerDelegate {
    var delegate: MediaPickerPresenter?
    var picker: UIDocumentPickerViewController
    
    init(picker: UIDocumentPickerViewController) {
        self.picker = picker
        super.init()
        picker.delegate = self
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            let file = FileInfo(withFileURL: url)
            delegate?.didSelectFromMediaPicker(file)
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
