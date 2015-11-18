//
//  PlaylistsController.swift
//  Ear Player
//
//  Created by Gabriel Bitencourt on 10/11/15.
//  Copyright © 2015 Gabriel Bitencourt. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlaylistController: UIViewController, UITableViewDataSource, UITableViewDelegate, MPMediaPickerControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.AnyAudio)
    var playlists = [String]()
    var mediaCollection: MPMediaItemCollection!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func newPlaylist(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Playlist Name", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler{(textField) -> Void in}
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
            
            let alertField = alert.textFields![0] as UITextField
            
            self.playlists.append(alertField.text!)
            
            self.mediaPicker.delegate = self
            self.mediaPicker.allowsPickingMultipleItems = true
            self.presentViewController(self.mediaPicker, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    //MPMediaPicker Protocols
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        mediaCollection = mediaItemCollection
        tableView.reloadData()
        
    }
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        
        dismissViewControllerAnimated(false, completion: nil)
        
    }
    
    //Table View
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("playlistCell", forIndexPath: indexPath)
        cell.textLabel?.text = playlists[indexPath.row]
        
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return playlists.count
    }

    
    //Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "fromCell"{
            let dtvc = segue.destinationViewController as! ViewController
            
            dtvc.playlistItems = mediaCollection
        }
        else if segue.identifier == "fromButton"{
            
        }
    }

}


