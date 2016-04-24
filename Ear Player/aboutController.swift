//
//  aboutController.swift
//  Ear Player
//
//  Created by Gabriel Bitencourt on 23/04/16.
//  Copyright © 2016 Gabriel Bitencourt. All rights reserved.
//

import UIKit

class aboutController: UIViewController {
    
    @IBOutlet weak var sidebarButton: UIBarButtonItem!
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sidebar menu
        sidebarButton.target = self.revealViewController()
        sidebarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        //Image
        image.clipsToBounds = true
        image.layer.cornerRadius = 75.0
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}