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
    
    //Plylists Set-up and Core Data
    var mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.AnyAudio)
    var playlistName = String()
    var playlists = [NSManagedObject]()
    
    //Protocols
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Get the delegate and the context
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        //Make the request
        let fetchRequest = NSFetchRequest(entityName: "Playlist")
        
        //Get the results
        do {
            let results =
            try context.executeFetchRequest(fetchRequest)
            playlists = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    //Create playlist
    @IBAction func newPlaylist(sender: AnyObject) {
        
        //Create the alert
        let alert = UIAlertController(title: "Playlist Name", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Alert text field set-up
        alert.addTextFieldWithConfigurationHandler{(textField) -> Void in}
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
            
            //Get the Text Field
            let alertField = alert.textFields![0] as UITextField
            
            self.playlistName = (alertField.text!)
            
            //Present the Media Picker
            self.mediaPicker.delegate = self
            self.mediaPicker.allowsPickingMultipleItems = true
            self.presentViewController(self.mediaPicker, animated: true, completion: nil)
            
        }))
        
        //Set the cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        //Present the alert
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    //MPMediaPicker Protocols
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(mediaItemCollection)
        let name = playlistName
        /*let date = NSDate*/
        
        saveName(name, songs: data)/*, date: date)*/
        tableView.reloadData()

    }
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        
        dismissViewControllerAnimated(false, completion: nil)
        
    }
    
    //Table View
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Get the cell
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("playlistCell", forIndexPath: indexPath)
        
        //Get the playlist data
        let playlist = playlists[indexPath.row]
        let name = playlist.valueForKey("name") as? String
        let playCount = playlist.valueForKey("playCount") as? Double
        let collectionData = playlist.valueForKey("songs") as! NSData
        
        //Unarchive the media collection
        let mediaCollection = NSKeyedUnarchiver.unarchiveObjectWithData(collectionData) as! MPMediaItemCollection
        let count = mediaCollection.items.count
        
        /*let date = NSDate()*/
        
        //Set the cell
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = "\(count) musicas, tocado \(Int(playCount!)) vezes"// - criado em \(date)"

        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return playlists.count
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        //Edit playlist action
        let editAction = UITableViewRowAction(style: .Normal, title: "Edit", handler: {action, indexPath -> Void in
            print("edit")
        })
        
        //Delete playlist action
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
            
            tableView.reloadData()
        })
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction, editAction]
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Get the delegate, context and the NSManagedObject
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let playlist = playlists[indexPath.row]
        
        //Set the new count
        let currentCount = (playlist.valueForKey("playCount") as? Double)! + 1
        playlist.setValue(currentCount, forKey: "playCount")
        
        //Save it
        do{
            try context.save()
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    
    //Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "fromCell"{
            //Get the destination view and the sender
            let dtvc = segue.destinationViewController as! ViewController
            let cell = sender as! UITableViewCell
            let index = tableView.indexPathForCell(cell)!
            
            //Pass the data
            let playlist = playlists[index.row]
            let songsData = playlist.valueForKey("songs") as? NSData
            let songs = NSKeyedUnarchiver.unarchiveObjectWithData(songsData!) as! MPMediaItemCollection
            dtvc.playlistItems = songs
        }
        else if segue.identifier == "fromButton"{
            
        }
    }
    
    //Core Data
    func saveName(name: String, songs: NSData){/*, date: NSDate, playCount: Double){*/
        //Get the delegate and context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        //Get the entity
        let entity = NSEntityDescription.entityForName("Playlist", inManagedObjectContext: context)
        let playlist = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
        
        //Set the values
        playlist.setValue(name, forKey: "name")
        playlist.setValue(songs, forKey: "songs")
        playlist.setValue(0, forKey: "playCount")
        //playlist.setValue(date, forKey: "date")
        
        //Save them
        do{
            try context.save()
            playlists.append(playlist)
            
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}


