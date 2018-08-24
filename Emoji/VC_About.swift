//
//  VC_About.swift
//  Emoji
//
//  Created by Erdem Arslan on 17.08.2018.
//  Copyright © 2018 Erdem Arslan. All rights reserved.
//

import UIKit


class VC_About: UIViewController {

    
    @IBOutlet weak var imageBack: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageBack.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(goBack))
        imageBack.addGestureRecognizer(gesture)
        
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
 

}
