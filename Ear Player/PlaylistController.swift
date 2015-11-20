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
import CoreData

class PlaylistController: UIViewController, UITableViewDataSource, UITableViewDelegate, MPMediaPickerControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.AnyAudio)
    var playlistName = String()
    var playlists = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Playlist")
        
        do {
            let results =
            try context.executeFetchRequest(fetchRequest)
            playlists = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func newPlaylist(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Playlist Name", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler{(textField) -> Void in}
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
            
            let alertField = alert.textFields![0] as UITextField
            
            self.playlistName = (alertField.text!)
            
            self.mediaPicker.delegate = self
            self.mediaPicker.allowsPickingMultipleItems = true
            self.presentViewController(self.mediaPicker, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    //MPMediaPicker Protocols
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(mediaItemCollection)
        let name = playlistName
        
        saveName(name, songs: data)
        tableView.reloadData()

    }
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        
        dismissViewControllerAnimated(false, completion: nil)
        
    }
    
    //Table View
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("playlistCell", forIndexPath: indexPath)
        
        let playlist = playlists[indexPath.row]
        
        cell.textLabel?.text = playlist.valueForKey("name") as? String

        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return playlists.count
    }
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let playlist = playlists[indexPath.row]
        
        let alert = UIAlertController(title: playlist.valueForKey("name") as? String, message: "info", preferredStyle: .Alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        
        alert.addAction(dismiss)
        presentViewController(alert, animated: true, completion: nil)
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .Normal, title: "Edit", handler: {action, indexPath -> Void in
            print("edit")
        })
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {action, indexPath -> Void in

            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = appDelegate.managedObjectContext
            
            context.deleteObject(self.playlists[indexPath.row] as NSManagedObject)
            self.playlists.removeAtIndex(indexPath.row)
            
            do{
                try context.save()
            } catch let error as NSError{
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()
        })
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction, editAction]
    }


    
    //Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "fromCell"{
            let dtvc = segue.destinationViewController as! ViewController
            let cell = sender as! UITableViewCell
            let index = tableView.indexPathForCell(cell)!
            
            let playlist = playlists[index.row]
            let songsData = playlist.valueForKey("songs") as? NSData
            let songs = NSKeyedUnarchiver.unarchiveObjectWithData(songsData!) as! MPMediaItemCollection
            dtvc.playlistItems = songs
        }
        else if segue.identifier == "fromButton"{
            
        }
    }
    
    
    //Core Data
    func saveName(name: String, songs: NSData){
        //Get the delegate and context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        //Get the entity
        let entity = NSEntityDescription.entityForName("Playlist", inManagedObjectContext: context)
        let playlist = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
        
        //Set the values
        playlist.setValue(name, forKey: "name")
        playlist.setValue(songs, forKey: "songs")
        
        //Save them
        do{
            try context.save()
            playlists.append(playlist)
            
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

}


