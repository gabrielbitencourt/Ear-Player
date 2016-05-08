//
//  podcastPlayer.swift
//  Ear Player
//
//  Created by Gabriel Bitencourt on 01/05/16.
//  Copyright © 2016 Gabriel Bitencourt. All rights reserved.
//

import UIKit

class poodcastPlayer: UIViewController {
    
    var podcast = RSSItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(podcast.link)
        print(podcast.author)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}