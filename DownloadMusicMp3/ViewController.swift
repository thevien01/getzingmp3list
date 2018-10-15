//
//  ViewController.swift
//  DownloadMusicMp3
//
//  Created by DKHT on 10/3/18.
//  Copyright © 2018 DKHT. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        downloadMp3()
    }

    override var representedObject: Any? {
        didSet {
        }
    }

    
    func downloadMp3(){
        if let albumUrl = URL(string: "https://mp3.zing.vn/playlist/bai-hat-cua-Duc-Phuc/IWZA66AO.html?list=song_artist_play"){
           
            ZingMp3Store.sharedInstance.getZingMp3SongList(listSongUrl: albumUrl)

        }
    }

}   

