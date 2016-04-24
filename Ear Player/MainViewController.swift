//
//  ViewController.swift
//  Ear Player
//
//  Created by Gabriel Bitencourt on 10/06/15.
//  Copyright © 2015 Gabriel Bitencourt. All rights reserved.
//  TE AMO EAR PLAYER <3
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, MPMediaPickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var musicArtwork: UIImageView!
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var sidebarButton: UIBarButtonItem!
    
    var counter: Int = 1 //(odd: pause, even: play)
    var counterDelete: Int = 0
    var deleted: Int = 0
    var touching: Bool = true
    var firstTime: Bool!
    var addLaterArray: [AVPlayerItem] = []
    
    //Audio variables
    var mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.AnyAudio)
    var audioPlayer: AVQueuePlayer!
    var mediaItems: AnyObject!
    
    //Metadata info
    var mediaArray: [AVPlayerItem] = []
    var musicTitleArray: [String] = []
    var musicArtworkArray: [AnyObject] = []
    var artworkImageArray: [UIImage] = []
    var toBeSkipped: [Int] = []
    
    //Add second time
    var newMedias: [AVPlayerItem] = []
    var newPlayer: AVQueuePlayer!
    
    //Core Data for Playlists
    var playlistItems: MPMediaItemCollection!

    //Protocols
    override func viewDidLoad() {
        super.viewDidLoad()

        //iOS 9
        let session = AVAudioSession.sharedInstance()
        do{
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.None)
            try! session.setActive(true)
        }
        
        
        //Proximity code
        UIDevice.currentDevice().proximityMonitoringEnabled = false
        
        //Notification Center
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(ViewController.sensorStateChanged), name: "UIDeviceProximityStateDidChangeNotification", object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.didPlayToEnd), name: "AVPlayerItemDidPlayToEndTimeNotification", object: nil)
        
        //Sidebar menu
        sidebarButton.target = self.revealViewController()
        sidebarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        //Playlists
        if playlistItems != nil{
            mediaPicker(MPMediaPickerController(), didPickMediaItems: playlistItems)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        
        mediaArray.removeAtIndex(0)
        musicTitleArray.removeAtIndex(0)
        
        
        if artworkImageArray != []{
            musicArtworkArray.removeAtIndex(0)
            artworkImageArray.removeAtIndex(0)
        }
        else if musicTitleArray == []{
            musicName.text = ""
        }
        else if mediaArray == []{
            
        }
        
        collection.reloadData()
    }
    func playingSystem(){

        for thisItem in mediaItems as! [MPMediaItem] {

            let itemUrl = thisItem.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL
            let playerItem = AVPlayerItem(URL: itemUrl!)
            var index: Int!

            if firstTime == true{
                mediaArray.append(playerItem)
            } else if firstTime == false {
                addLaterArray.append(playerItem)
            }
            musicTitleArray.append(thisItem.title!)

            //Road to display images (so long, so cruel)
            do{
                var image: AnyObject!
                if thisItem.artwork == nil{
                    image = UIImage(named: "noArtwork")
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
            }
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
            musicArtwork.image = UIImage(named: "noArtwork")
        }
        
    }
    @IBAction func playAudio(sender: AnyObject) {
        
        counter += 1
        
        if counter % 2 == 0{
            playButton.titleLabel?.font = UIFont(name: "Marker Felt", size: 55.0)
            playButton.setTitle("||", forState: .Normal)
            UIDevice.currentDevice().proximityMonitoringEnabled = true

            updateMetadata()
        }
        else if counter % 2 == 1 {
            playButton.titleLabel?.font = UIFont(name: "Marker Felt", size: 72.0)
            playButton.setTitle(">", forState: .Normal)
            UIDevice.currentDevice().proximityMonitoringEnabled = false

            updateMetadata()
        }
        
        
    }
    @IBAction func addMusic(sender: AnyObject) {
        
        self.mediaPicker.delegate = self
        self.mediaPicker.allowsPickingMultipleItems = true
        self.presentViewController(self.mediaPicker, animated: true, completion: nil)
        
    }
    @IBAction func advance(sender: AnyObject) {
        if mediaArray.count >= 2 {
            audioPlayer.advanceToNextItem()
            didPlayToEnd()
            updateMetadata()
        }
        else if mediaArray.count == 1{
            didPlayToEnd()
            updateMetadata()
        }
    }
    @IBAction func getback(sender: AnyObject) {
        if mediaArray.count >= 1{
            audioPlayer.currentItem?.seekToTime(CMTimeMakeWithSeconds(0, 1))
        }
    }
    
    //Collection View
    func touched(sender: AnyObject) {
        touching = false
        collection.reloadData()
    }
    @IBAction func tapped(sender: AnyObject) {
        touching = true
        collection.reloadData()
    }

    
    //Player protocols
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {

        if mediaArray == []{
            firstTime = true
            
            audioPlayer = nil
            mediaArray = []
            musicTitleArray = []
            musicArtworkArray = []
            artworkImageArray = []
            toBeSkipped = []
            deleted = 0
        } else {
            firstTime = false
        }

        collection.reloadData()
        mediaItems = mediaItemCollection.items

        playingSystem()
        updateMetadata()

        if firstTime == true{
            audioPlayer = AVQueuePlayer(items: mediaArray)

        } else if firstTime == false {
            for item in addLaterArray {
                audioPlayer.insertItem(item, afterItem: mediaArray[mediaArray.count - 1])
                mediaArray.append(item)
                addLaterArray.removeAtIndex(0)
            }
        }
        
        collection.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        
        dismissViewControllerAnimated(false, completion: nil)
        
    }
    
    
    //Collection View Protocols
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: CellController = collection.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CellController
        
        
        cell.imageView.image = UIImage(named: "noArtwork")
        cell.imageView.image = artworkImageArray[indexPath.row + 1]
        
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.touched(_:)))
        cell.addGestureRecognizer(longTouch)
        
        cell.label.text = "\(indexPath.row + 2). " + musicTitleArray[indexPath.row + 1]
        cell.exitButton.hidden = touching
        cell.exitButton.layer.setValue(indexPath.row, forKey: "index")
        cell.exitButton.addTarget(self, action: #selector(ViewController.deleteCell(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if mediaArray.count == 0{
            return 0
            
        }
        else{
            return mediaArray.count - 1
        }

    }
    
    func deleteCell(sender: AnyObject){
        var item = Int()
        
        item = sender.layer.valueForKey("index") as! Int + 1

        
        audioPlayer.removeItem(mediaArray[item])

        musicTitleArray.removeAtIndex(item)
        mediaArray.removeAtIndex(item)
        
        if artworkImageArray != []{
            musicArtworkArray.removeAtIndex(item)
            artworkImageArray.removeAtIndex(item)
        }
        
        if musicTitleArray == []{
            audioPlayer.removeAllItems()
            updateMetadata()
        }
        
        updateMetadata()
        collection.reloadData()
        touching = true
    }
    
    //Segues
    @IBAction func exit(sender: UIStoryboardSegue){
        if sender.identifier == "fromCell"{
            mediaPicker(MPMediaPickerController(), didPickMediaItems: playlistItems)
        }
    }
}