//
//  ZingMp3Store.swift
//  DownloadMusicMp3
//
//  Created by DKHT on 10/4/18.
//  Copyright © 2018 DKHT. All rights reserved.
//

import Foundation
import SwiftSoup
import AFNetworking

class ZingMp3Store: NSObject {
    
    static let sharedInstance = ZingMp3Store()
    
    func getSong(id: String)-> SongModel?{
      
        let songLink  = ZingMp3Constants.getURLSongWith(id: id)
        guard let url = URL(string: songLink) else {
            return nil
        }

        do {
            let htmlContent  = try String(contentsOf: url, encoding: .utf8)
            let doc          = try SwiftSoup.parse(htmlContent)
            let contentIdDoc = try doc.getElementById("zplayerjs-wrapper")
            
            if let key         = contentIdDoc!.getAttributes()?.get(key: "data-xml"){
                let contentApi = ZingMp3Constants.MP3_URL_SERVER_API + "/" + key
                if let detailContentURl = URL(string: contentApi){
                    let song            = self.getZingMp3Song(url: detailContentURl)
                    print(song)
                }
                
                print(contentApi)
            }
            print(htmlContent)
        }catch let error{
            print(error.localizedDescription)
            return nil
        }

        return nil
    }

    func getZingMp3Song(url: URL)-> SongModel{
        do {
            let jsonString = try String(contentsOf: url)
            print(jsonString)
            if let data = jsonString.data(using: String.Encoding.utf8){
                let json = try JSONSerialization.jsonObject(with:  data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                print(json)
                
                let songData = json["data"] as! [String: Any]
                let newSong  = SongModel(dics: songData)
                return newSong
            }
        }catch let error{
            print(error)
        }
        return SongModel()
    }
    
    func getZingMp3SongList(listSongUrl: URL)-> [SongModel]?{
        var result = [SongModel]()
        do {
            let contentHtml = try String(contentsOf: listSongUrl)
            let doc         = try SwiftSoup.parse(contentHtml)
            
            guard let idDiv = try doc.getElementById("zplayerjs-wrapper") else {
                return nil
            }
            guard let attributes = idDiv.getAttributes() else{
                return nil
            }
            
            var link = attributes.get(key: "data-xml")
            
            if !link.isEmpty{
                link = ZingMp3Constants.MP3_URL_SERVER_API + link
            }
            
            if let url = URL(string: link){
                let contentHtml    = try String(contentsOf: url)
                if let jsonData    = contentHtml.data(using: String.Encoding.utf8){
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                    print(json)
                    
                    if let dataList = json["data"] as? [String: Any]{
                        if let list = dataList["items"] as? NSArray{
                            print(list)
                            
                            for item in list{
                                let newSong = SongModel(dics: item as! [String: Any])
                                result.append(newSong)
                            }
                            return result
                        }
                    }

                }
            }
        }catch let error {
            print(error.localizedDescription)
        }
        return [SongModel]()
    }
    
    func downloadMp3File(fileName: String,
                         url: URL,
                         desinationPath: String,
                         completion: @escaping((_ finish: Bool, _ error: Error?)-> Void),
                         progressDownloaded: @escaping((_ progress: Double)->Void)){
        
        let sessionConfig  = URLSessionConfiguration.default
        let sessionManager = AFURLSessionManager.init(sessionConfiguration: sessionConfig)
        let request        = URLRequest(url: url)

        sessionManager.downloadTask(with: request, progress: { (progress) in
            print(progress.fractionCompleted)
            progressDownloaded(progress.fractionCompleted)
        }, destination: { (url, urlResponse) -> URL in
            return URL(fileURLWithPath: desinationPath).appendingPathComponent(fileName)
        }) { (response, tempUrl, tempError) in
            if tempError == nil {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                    completion(true, nil)
                }
            }
        }.resume()
    }
}
