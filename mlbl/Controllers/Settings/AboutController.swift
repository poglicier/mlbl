//
//  AboutController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 06.12.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class AboutController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
    }
    
    // MARK: - Private
    
    @IBOutlet fileprivate var imageView: UIImageView!
    @IBOutlet fileprivate var textView: UITextView!
    
    fileprivate func setupViews() {
        if let _ = self.imageURL {
            self.imageView.setImageWithUrl(self.imageURL!)
        } else {
            self.imageView.image = self.image
        }
        
        self.textView.text = self.text
    }
    
    // MARK: - Public
    
    var image: UIImage?
    var imageURL: URL?
    var text: String?
}
