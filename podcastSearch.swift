//
//  podcastSearch.swift
//  Ear Player
//
//  Created by Gabriel Bitencourt on 01/05/16.
//  Copyright © 2016 Gabriel Bitencourt. All rights reserved.
//

import UIKit

let baseURL = "https://itunes.apple.com/search"
class podcastSearch: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var sidebarButton: UIBarButtonItem!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var collection: UICollectionView!
    
    var results = [[String: AnyObject]]()
    
    var index = Int()
    
    //Protocols
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sidebar menu
        sidebarButton.target = self.revealViewController()
        sidebarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
    }
    
    @IBAction func search(sender: AnyObject) {
        
        let methodArguments = [
            "term": searchText.text!,
            "media": "podcast",
            "attribute": "artistTerm",
            "country": "BR",
            "limit": "25"
        ]
        
        let session = NSURLSession.sharedSession()
        let urlString = baseURL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)
        print(urlString)
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request){data, response, downloadError in
            
            //Check if there's an error
            if let error = downloadError{
                print(error)
            }
            else{
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                print(parsedResult)
                
                let podcasts = parsedResult.valueForKey("results") as! [[String: AnyObject]]

                self.results = podcasts
                self.collection.reloadData()

            }
        }
        task.resume()
    }
    
    //Collection View
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if results == []{
            return 0
        }
        else {
            return results.count
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: PCellController = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PCellController
        
        let imageURLS = results[indexPath.row]["artworkUrl100"] as? String
        let imageURLM = NSURL(string: imageURLS!)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            let imageData = NSData(contentsOfURL: imageURLM!)
            cell.imageView.image = UIImage(data: imageData!)
            cell.label.text = self.results[indexPath.row]["artistName"] as? String

            
        })
        
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        index = indexPath.row
        
    }
    
    //Helper function: Given a dictionary of parameters, convert to a string for a url
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let dtvc = segue.destinationViewController as! podcastSelect
        
        if segue.identifier == "podcast"{
            dtvc.feedURL = results[index]["feedUrl"] as! String
            
        }
    }
 
}