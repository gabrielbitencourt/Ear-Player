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

class ViewController: UIViewController, MPMediaPickerControllerDelegate, ADBannerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var musicArtwork: UIImageView!
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var adBanner: ADBannerView!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet var longTouch: UILongPressGestureRecognizer!
    
    
    var counter: Int = 1 //To make soundEnabler work (odd: not enabled, even: enabled)
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
    
    var newMedias: [AVPlayerItem] = []
    var newPlayer: AVQueuePlayer!
    
    var playlistItems: MPMediaItemCollection!
    
    
    //Protocols
    override func viewDidLoad() {
        super.viewDidLoad()
        print("did load")

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
        notificationCenter.addObserver(self, selector: Selector("sensorStateChanged"), name: "UIDeviceProximityStateDidChangeNotification", object: nil)
        notificationCenter.addObserver(self, selector: Selector("didPlayToEnd"), name: "AVPlayerItemDidPlayToEndTimeNotification", object: nil)

        
        //iAd code
        adBanner.delegate = self
        adBanner.hidden = true

        musicArtwork.layer.cornerRadius = 10.0
        musicArtwork.clipsToBounds = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("will appear")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("did appear")
    }
    
    //iAd
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adBanner.hidden = false
    }
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adBanner.hidden = true
        
    }

    @IBAction func tutorial(sender: AnyObject) {
        
        
        let tutorial = UIAlertController(title: "Help", message: "1. The musics will play in the order that you select;\n2. Adding more musics won't replace the ones in the queue;\n3. The music will pause if you remove the phone from the ear.", preferredStyle: UIAlertControllerStyle.Alert)

        let ok = UIAlertAction(title: "Ok, got it!", style: UIAlertActionStyle.Cancel, handler: nil)
            tutorial.addAction(ok)
            
        self.presentViewController(tutorial, animated: true, completion: nil)


        
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
        
        if musicTitleArray == []{
            musicName.text = ""
        }
        
        if mediaArray == []{
            
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
    
    //Music shit
    @IBAction func playAudio(sender: AnyObject) {
        
        counter++
        
        if counter % 2 == 0{
            playButton.setTitle("||", forState: .Normal)
            UIDevice.currentDevice().proximityMonitoringEnabled = true

            updateMetadata()
        }
        else if counter % 2 == 1 {
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
    
    //Collection View Shit
    @IBAction func touched(sender: AnyObject) {
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
    
    
    //Collection View
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: CellController = collection.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CellController
        
        
        cell.imageView.image = UIImage(named: "noArtwork")
        
        cell.imageView.image = artworkImageArray[indexPath.row + 1]
        
        cell.imageView.layer.cornerRadius = 10.0
        cell.imageView.clipsToBounds = true
        
        cell.label.text = "\(indexPath.row + 2). " + musicTitleArray[indexPath.row + 1]
        cell.exitButton.hidden = touching
        cell.exitButton.layer.setValue(indexPath.row, forKey: "index")
        cell.exitButton.addTarget(self, action: "deleteCell:", forControlEvents: UIControlEvents.TouchUpInside)
        
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