//
//  ViewController.swift
//  Ear Player
//
//  Created by Gabriel Bitencourt on 10/06/15.
//  Copyright © 2015 Gabriel Bitencourt. All rights reserved.
//
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
    var mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.anyAudio)
    var audioPlayer: AVQueuePlayer!
    var mediaItems: AnyObject!
    
    //Metadata info
    var mediaArray: [AVPlayerItem] = []
    var musicTitleArray: [String] = []
    var musicArtworkArray: [AnyObject] = []
    var artworkImageArray: [UIImage] = []
    var toBeSkipped: [Int] = []
    
    //Core Data for Playlists
    var playlistItems: MPMediaItemCollection!
    
    //Notification Center
    let notificationCenter = NotificationCenter.default
    
    //Slider
    @IBOutlet weak var slider: UISlider!
    
    //Protocols
    override func viewDidLoad() {
        super.viewDidLoad()

        //iOS 9
        let session = AVAudioSession.sharedInstance()
        do{
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
            try! session.setActive(true)
        }
        
        
        //Proximity code
        UIDevice.current.isProximityMonitoringEnabled = false
        
        //Notification Center
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ViewController.sensorStateChanged), name: NSNotification.Name(rawValue: "UIDeviceProximityStateDidChangeNotification"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.didPlayToEnd), name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
        
        //Sidebar menu
        sidebarButton.target = self.revealViewController()
        sidebarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        //Playlists
        if playlistItems != nil{
            mediaPicker(MPMediaPickerController(), didPickMediaItems: playlistItems)
        }
    }
    
    //Music func's
    @objc func sensorStateChanged(){
        
        if mediaArray != []{
            
            if UIDevice.current.proximityState && counter % 2 == 0{
                audioPlayer.play()
            }
            else {
                updateMetadata()
                audioPlayer.pause()
                
            }
        }
    }
    @objc func didPlayToEnd(){
        
        mediaArray.remove(at: 0)
        musicTitleArray.remove(at: 0)

        
        if artworkImageArray != []{
            musicArtworkArray.remove(at: 0)
            artworkImageArray.remove(at: 0)
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

            let itemUrl = thisItem.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
            let playerItem = AVPlayerItem(url: itemUrl!)
            var index: Int!

            if firstTime == true{
                mediaArray.append(playerItem)
            } else if firstTime == false {
                addLaterArray.append(playerItem)
            }
            musicTitleArray.append(thisItem.title!)

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
                    artworkImageArray.append(musicArtworkArray[index].image(at: CGSize(width: 143, height: 143))!)
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
            musicName.text = "Choose a music"
        }
        if artworkImageArray != []{
            musicArtwork.image = artworkImageArray[0]
            
        } else {
            musicArtwork.image = UIImage(named: "noArtwork")
        }

        
    }
    
    @IBAction func playAudio(_ sender: AnyObject) {
        
        counter += 1
        
        if counter % 2 == 0{
            playButton.setTitle("||", for: UIControlState())
            UIDevice.current.isProximityMonitoringEnabled = true
            //notificationCenter.addObserver(self.audioPlayer, forKeyPath: "currentItem.duration", options: NSKeyValueObservingOptions.Initial, context: nil)
            updateMetadata()

        }
        else if counter % 2 == 1 {
            playButton.setTitle(">", for: UIControlState())
            UIDevice.current.isProximityMonitoringEnabled = false

            updateMetadata()
        }
        
        
    }
    @IBAction func addMusic(_ sender: AnyObject) {
        
        self.mediaPicker.delegate = self
        self.mediaPicker.allowsPickingMultipleItems = true
        self.present(self.mediaPicker, animated: true, completion: nil)
        
    }
    @IBAction func advance(_ sender: AnyObject) {
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
    @IBAction func getback(_ sender: AnyObject) {
        if mediaArray.count >= 1{
            audioPlayer.currentItem?.seek(to: CMTimeMakeWithSeconds(0, 1))
        }
    }
    @IBAction func changeTime(_ sender: AnyObject) {
    }
    
    //Collection View
    @objc func touched(_ sender: AnyObject) {
        touching = false
        collection.reloadData()
    }
    @IBAction func tapped(_ sender: AnyObject) {
        touching = true
        collection.reloadData()
    }

    
    //Player protocols
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {

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
        mediaItems = mediaItemCollection.items as AnyObject!

        playingSystem()
        updateMetadata()

        if firstTime == true{
            audioPlayer = AVQueuePlayer(items: mediaArray)

        } else if firstTime == false {
            for item in addLaterArray {
                audioPlayer.insert(item, after: mediaArray[mediaArray.count - 1])
                mediaArray.append(item)
                addLaterArray.remove(at: 0)
            }
        }
        
        collection.reloadData()
        self.dismiss(animated: true, completion: nil)
        
    }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        
        dismiss(animated: false, completion: nil)
        
    }
    
    
    //Collection View Protocols
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CellController = collection.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CellController
        
        cell.imageView.image = artworkImageArray[indexPath.row + 1]
        
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.touched(_:)))
        cell.addGestureRecognizer(longTouch)
        
        cell.label.text = "\(indexPath.row + 2). " + musicTitleArray[indexPath.row + 1]
        cell.exitButton.isHidden = touching
        cell.exitButton.layer.setValue(indexPath.row, forKey: "index")
        cell.exitButton.addTarget(self, action: #selector(ViewController.deleteCell(_:)), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if mediaArray.count == 0{
            return 0
            
        }
        else{
            return mediaArray.count - 1
        }

    }
    
    @objc func deleteCell(_ sender: AnyObject){
        var item = Int()
        
        item = sender.layer.value(forKey: "index") as! Int + 1

        
        audioPlayer.remove(mediaArray[item])

        musicTitleArray.remove(at: item)
        mediaArray.remove(at: item)
        
        if artworkImageArray != []{
            musicArtworkArray.remove(at: item)
            artworkImageArray.remove(at: item)
        }
        
        if musicTitleArray == []{
            audioPlayer.removeAllItems()
            updateMetadata()
        }
        
        updateMetadata()
        collection.reloadData()
        touching = true
    }
    /*
    override func didChangeValueForKey(key: String) {
        super.didChangeValueForKey(key)
        
        if key == "currentItem.duration"{
            print(audioPlayer.currentItem?.duration)
        }
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "currentItem.duration"{
            print(audioPlayer.currentItem?.duration)
        }
        //super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)

    }
    */
}
