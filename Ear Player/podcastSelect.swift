//
//  podcastSelect.swift
//  Ear Player
//
//  Created by Gabriel Bitencourt on 01/05/16.
//  Copyright © 2016 Gabriel Bitencourt. All rights reserved.
//

import UIKit

class podcastSelect: UIViewController, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var podImage: UIImageView!
    @IBOutlet weak var podTitle: UILabel!
    @IBOutlet weak var podDescription: UITextView!
    @IBOutlet weak var tableView: UITableView!
    

    var feedURL: String!
    var feed = RSSFeed()
    
    var index = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request: NSURLRequest = NSURLRequest(URL: NSURL(string: feedURL)!)
            
            RSSParser.parseFeedForRequest(request, callback: { (feedP, error) -> Void in
                
                self.feed = feedP!
                self.tableView.reloadData()

            })
        
        
    }

    //Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return feed.items.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = feed.items[indexPath.row].title
        cell.detailTextLabel?.text = "\(feed.items[indexPath.row].pubDate)"
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        index = indexPath.row
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let dtvc = segue.destinationViewController as! poodcastPlayer
        
        if segue.identifier == ""{
            dtvc.podcast = feed.items[index]
    }
    }
}