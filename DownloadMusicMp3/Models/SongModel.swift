//
//  SongModel.swift
//  DownloadMusicMp3
//
//  Created by DKHT on 10/4/18.
//  Copyright © 2018 DKHT. All rights reserved.
//

import Foundation

class SongModelConstant{
    
    static let ID        = "id"
    static let CODE      = "code"
    static let TITLE     = "title"
    static let SOURCE    = "source"
    static let THUMBNAIL = "thumbnail"
    static let DURATION  = "duration"
    static let LINK      = "link"

}

enum DownloadStatus: String{
    case downloaded   = "Downloaded"
    case downloading  = "Downloading"
    case exist        = "Exist"
    case downloadFail = "Download fail"
    case none         = "none"
}

class SongModel: NSObject{
    var code    = ""
    var title   = ""
    var artists = ""
    var duration: Double = 0.0
    var link             = ""
    var thumbnail        = ""
    var source128           = ""
    var progressDownloaded: Double = 0.0
    var statusDownload: DownloadStatus = .none
    
    override init() {
        
    }
    
    init(title: String, artists: String, duration: Double, link: String, thumbnail: String, source: String) {
        self.title     = title
        self.artists   = artists
        self.duration  = duration
        self.link      = link
        self.thumbnail = thumbnail
        self.source128    = source
    }
    
    init(dics: [String: Any]) {
        if let title   = dics[SongModelConstant.TITLE] as? String{
            self.title = title
        }
        
        if let code   = dics[SongModelConstant.CODE] as? String{
            self.code = code
        }
        
        if let thumbnail   = dics[SongModelConstant.THUMBNAIL] as? String{
            self.thumbnail = thumbnail
        }
        
        if let duration    = dics[SongModelConstant.DURATION] as? Double{
            self.duration  = duration
        }
        
        if let link   = dics[SongModelConstant.LINK] as? String{
            self.link = link
        }
        
        if let sourcesDics = dics[SongModelConstant.SOURCE] as? [String: Any]{
            if let source_128 = sourcesDics["128"] as? String{
                self.source128 = source_128
            }
        }
        
    }
}
