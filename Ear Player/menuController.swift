//
//  menuController.swift
//  Ear Player
//
//  Created by Gabriel Bitencourt on 23/04/16.
//  Copyright © 2016 Gabriel Bitencourt. All rights reserved.
//

import UIKit

class menuController: UITableViewController {
    
    @IBOutlet weak var aboutImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 0.92, alpha: 1)
        
        aboutImage.clipsToBounds = true
        aboutImage.layer.cornerRadius = 25
        
    }

}