//
//  PlaylistsController.swift
//  Ear Player
//
//  Created by Gabriel Bitencourt on 10/11/15.
//  Copyright © 2015 Gabriel Bitencourt. All rights reserved.
//

import UIKit

class PlaylistController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    //Table View
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
}


