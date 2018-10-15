//
//  ZingMp3Constants.swift
//  DownloadMusicMp3
//
//  Created by DKHT on 10/4/18.
//  Copyright © 2018 DKHT. All rights reserved.
//

import Foundation

class ZingMp3Constants: NSObject{
    private static let MP3_URL_SONG = "https://mp3.zing.vn/bai-hat"
    static let MP3_URL_SERVER_API   = "https://mp3.zing.vn/xhr"
    
    static func getURLSongWith(id: String)-> String{
        return ZingMp3Constants.MP3_URL_SONG + "/" + id + ".html"
    }
}
