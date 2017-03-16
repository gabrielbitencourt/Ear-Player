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
    @IBOutlet weak var sidebarButton: UIBarButtonItem!

    //Plylists Set-up and Core Data
    var mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.anyAudio)
    var playlistName = String()
    var playlists = [NSManagedObject]()
    
    //Protocols
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sidebar
        sidebarButton.target = self.revealViewController()
        sidebarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())

        //proximity
        UIDevice.current.isProximityMonitoringEnabled = false

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Get the delegate and the context
        let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        //Make the request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        
        //Get the results
        do {
            let results =
            try context.fetch(fetchRequest)
            playlists = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    //Create playlist
    @IBAction func newPlaylist(_ sender: AnyObject) {
        
        //Create the alert
        let alert = UIAlertController(title: "Playlist Name", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        //Alert text field set-up
        alert.addTextField{(textField) -> Void in}
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) -> Void in
            
            //Get the Text Field
            let alertField = alert.textFields![0] as UITextField
            
            self.playlistName = (alertField.text!)
            
            //Present the Media Picker
            self.mediaPicker.delegate = self
            self.mediaPicker.allowsPickingMultipleItems = true
            self.present(self.mediaPicker, animated: true, completion: nil)
            
        }))
        
        //Set the cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        //Present the alert
        present(alert, animated: true, completion: nil)
        
        
    }
    
    //MPMediaPicker Protocols
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: mediaItemCollection)
        let name = playlistName
        
        saveName(name, songs: data)
        tableView.reloadData()

    }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        
        dismiss(animated: false, completion: nil)
        
    }
    
    //Table View
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Get the cell
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        
        //Get the playlist data
        let playlist = playlists[indexPath.row]
        let name = playlist.value(forKey: "name") as? String
        let playCount = playlist.value(forKey: "playCount") as? Double
        let collectionData = playlist.value(forKey: "songs") as! Data
        
        //Unarchive the media collection
        let mediaCollection = NSKeyedUnarchiver.unarchiveObject(with: collectionData) as! MPMediaItemCollection
        let count = mediaCollection.items.count
        
        //Set the cell
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = "\(count) musicas, tocado \(Int(playCount!)) vezes"
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return playlists.count
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //Delete playlist action
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: {action, indexPath -> Void in
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.managedObjectContext
            
            context.delete(self.playlists[indexPath.row] as NSManagedObject)
            self.playlists.remove(at: indexPath.row)
            
            do{
                try context.save()
            } catch let error as NSError{
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            tableView.reloadData()
        })
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Get the delegate, context and the NSManagedObject
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let playlist = playlists[indexPath.row]
        
        //Set the new count
        let currentCount = (playlist.value(forKey: "playCount") as? Double)! + 1
        playlist.setValue(currentCount, forKey: "playCount")
        
        //Save it
        do{
            try context.save()
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    
    //Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "playlist"{
            //Get the destination view and the sender
            let nav = segue.destination as! UINavigationController
            let dtvc = nav.topViewController as! ViewController
            let cell = sender as! UITableViewCell
            let index = tableView.indexPath(for: cell)!
            
            //Pass the data
            let playlist = playlists[index.row]
            let songsData = playlist.value(forKey: "songs") as? Data
            let songs = NSKeyedUnarchiver.unarchiveObject(with: songsData!) as! MPMediaItemCollection
            
            dtvc.playlistItems = songs

        }
        else if segue.identifier == "fromButton"{
            
        }
    }
    
    //Core Data
    func saveName(_ name: String, songs: Data){
        
        //Get the delegate and context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        //Get the entity
        let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: context)
        let playlist = NSManagedObject(entity: entity!, insertInto: context)
        
        //Set the values
        playlist.setValue(name, forKey: "name")
        playlist.setValue(songs, forKey: "songs")
        playlist.setValue(0, forKey: "playCount")
        
        //Save them
        do{
            try context.save()
            playlists.append(playlist)
            
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}


