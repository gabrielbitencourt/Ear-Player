//
//  ViewController.swift
//  Ear Player
//
//  Created by Gabriel Bitencourt on 10/06/15.
//  Copyright © 2015 Gabriel Bitencourt. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import iAd

class MainViewController: UIViewController, MPMediaPickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var musicArtwork: UIImageView!
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adBanner: ADBannerView!
    
    
    var counter: Int = 1 //To make soundEnabler work (odd: not enabled, even: enabled)
    var counterDelete: Int = 0
    var deleted: Int = 0

    
    //Audio variables
    var mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.Music)
    var audioPlayer: AVQueuePlayer!
    var mediaItems: AnyObject!
    
    //Metadata info
    var mediaArray: [AVPlayerItem] = []
    var musicTitleArray: [String] = []
    var musicArtworkArray: [AnyObject] = []
    var artworkImageArray: [UIImage] = []
    var toBeSkipped: [Int] = []    
    
    
    //Protocol (lots, and lots of'em)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Speaker code (NOT WORKING ON IOS9)
        if UIDevice.currentDevice().systemVersion == "8.3"{
            print("CURENTLY NOT WORKING")
        }
        else{
            print(UIDevice.currentDevice().systemVersion)
            let session = AVAudioSession.sharedInstance()
            //var error: NSError?
            do{
                try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.None)
                try! session.setActive(true)
            }
            
        }
        
        //Proximity code
        UIDevice.currentDevice().proximityMonitoringEnabled = true
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("sensorStateChanged"), name: "UIDeviceProximityStateDidChangeNotification", object: nil)
        notificationCenter.addObserver(self, selector: Selector("didPlayToEnd"), name: "AVPlayerItemDidPlayToEndTimeNotification", object: nil)
        
        //iAd code
        self.canDisplayBannerAds = true
        adBanner.delegate = self
        adBanner.hidden = true
        
        //Table view code
        tableView.allowsMultipleSelectionDuringEditing = false
        
        //First Launch
        let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
        if firstLaunch{
            print("not first launch")
        }
        else{
            print("first launch")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
        }
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    //iAd
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adBanner.hidden = false
    }
    
    //Music func's
    func sensorStateChanged(){
        
        if mediaArray != []{
            
            if UIDevice.currentDevice().proximityState && counter % 2 == 0{
                audioPlayer.play()
            }
            else {
                updateMetadata()
                audioPlayer.pause()
                
            }
            
        }
        
    }
    func didPlayToEnd(){
        //counterDelete++
        
        /*if toBeSkipped != []{
            
            if counterDelete == toBeSkipped[0]{
                
                let index = toBeSkipped[0]
                
                audioPlayer.removeItem(mediaArray[index])
                musicTitleArray.removeAtIndex(index)
                
                if artworkImageArray != []{
                    musicArtworkArray.removeAtIndex(index)
                    artworkImageArray.removeAtIndex(index)
                }
                
                if musicTitleArray == []{
                    audioPlayer.removeAllItems()
                    updateMetadata()
                }

            }
            
            toBeSkipped.removeAtIndex(0)
            updateMetadata()
            tableView.reloadData()

        }*/
        
        mediaArray.removeAtIndex(0)
        musicTitleArray.removeAtIndex(0)
        
        
        if artworkImageArray != []{
            musicArtworkArray.removeAtIndex(0)
            artworkImageArray.removeAtIndex(0)
        }
        
        if musicTitleArray == []{
            musicName.text = ""
        }
        
        tableView.reloadData()
    }
    func playingSystem(){
        
        for thisItem in mediaItems as! [MPMediaItem] {
            
            let itemUrl = thisItem.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL
            let playerItem = AVPlayerItem(URL: itemUrl!)
            var index: Int!
            
            mediaArray.append(playerItem)
            musicTitleArray.append(thisItem.title!)
            
            //Road to display images (so long, so cruel)
            var image: AnyObject!
            if thisItem.artwork == nil{
                image = UIImage(named: "cover")
            }
            else{
                image = thisItem.artwork
            }
            musicArtworkArray.append(image)
            index = musicArtworkArray.count - 1
            if musicArtworkArray[index] is UIImage{
                artworkImageArray.append(musicArtworkArray[index] as! UIImage)
            }
            else{
                artworkImageArray.append(musicArtworkArray[index].imageWithSize(CGSizeMake(143, 143))!)
            }
            musicArtwork.image = artworkImageArray[0]
            //End of it, congrats!
        }
        
    }
    func updateMetadata(){
        
        if musicTitleArray != []{
            musicName.text = musicTitleArray[0]
        } else {
            musicName.text = ""
        }
        if artworkImageArray != []{
            musicArtwork.image = artworkImageArray[0]
            
        } else {
            musicArtwork.image = UIImage(named: "cover")
        }
        
    }
    func shuffleArray() -> [AVPlayerItem]{
        
        //var count = mediaArray.count - 1
        var newShuffledArray: [AVPlayerItem] = []
        
        while mediaArray != []{
            
            let newObject = mediaArray[Int(arc4random_uniform(UInt32(mediaArray.count - 1)))]
            if newShuffledArray.contains(newObject) == false{
                newShuffledArray.append(newObject)
            }
            mediaArray.removeAtIndex(Int(arc4random_uniform(UInt32(mediaArray.count - 1))))
            
        }
        
        
        return newShuffledArray
    }
    
    
    
    
    
    //Music shit
    @IBAction func playAudio(sender: AnyObject) {
        
        counter++
        
        if counter % 2 == 0{
            playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
            
            updateMetadata()
            
        }
        else if counter % 2 == 1 {
            playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)

            updateMetadata()
            
        }
        
        
    }
    @IBAction func addMusic(sender: AnyObject) {
        
        self.mediaPicker.delegate = self
        self.mediaPicker.allowsPickingMultipleItems = true
        self.presentViewController(self.mediaPicker, animated: true, completion: nil)
        
    }
    @IBAction func shuffle(sender: AnyObject){
        audioPlayer.removeAllItems()
        //let newShuffledArray = shuffleArray()
    }

    
    
    //Player protocols
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        audioPlayer = nil
        mediaArray = []
        musicTitleArray = []
        musicArtworkArray = []
        artworkImageArray = []
        toBeSkipped = []
        deleted = 0
        
        tableView.reloadData()
        mediaItems = mediaItemCollection.items
        
        playingSystem()
        updateMetadata()
        
        audioPlayer = AVQueuePlayer(items: mediaArray)
        
        tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        
        dismissViewControllerAnimated(false, completion: nil)
        
    }
    
    
    //Table view shit
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell! = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = "\(indexPath.row + 1). " + musicTitleArray[indexPath.row]
        
        if artworkImageArray[indexPath.row] != []{
            cell.imageView?.image = artworkImageArray[indexPath.row]
        }

        
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if mediaArray.count == 0{
            
            return 0
            
        }
        else{
            return mediaArray.count - deleted
        }
        
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            deleted++
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            toBeSkipped.append(indexPath.row)
            /*if toBeSkipped[0] == 0{
                
                audioPlayer.removeItem(mediaArray[0])
                musicTitleArray.removeAtIndex(0)
                
                if artworkImageArray != []{
                    musicArtworkArray.removeAtIndex(0)
                    artworkImageArray.removeAtIndex(0)
                }
                
                toBeSkipped.removeAtIndex(0)
                updateMetadata()
                tableView.reloadData()
                
            }*/
            
            for item in toBeSkipped{
                
                audioPlayer.removeItem(mediaArray[item])
                musicTitleArray.removeAtIndex(item)
                
                if artworkImageArray != []{
                    musicArtworkArray.removeAtIndex(item)
                    artworkImageArray.removeAtIndex(item)
                }
                
                if musicTitleArray == []{
                    audioPlayer.removeAllItems()
                    updateMetadata()
                }


                updateMetadata()
                tableView.reloadData()
            }

            
        }
    }
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "X"
    }
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return false
    }
    

}