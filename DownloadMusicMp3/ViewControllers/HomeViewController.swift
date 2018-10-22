//
//  HomeViewController.swift
//  DownloadMusicMp3
//
//  Created by DKHT on 10/7/18.
//  Copyright © 2018 DKHT. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController{
    
    @IBOutlet weak var linkDownloadTextField: NSTextField!
    @IBOutlet weak var pathToSaveTextField: NSTextField!
    let sema = DispatchSemaphore(value: 0)

    @IBOutlet weak var tableView: NSTableView!
    
    var list = [SongModel]()
    
    override func viewDidLoad() {

        self.tableView.delegate   = self
        self.tableView.dataSource = self
        
        self.linkDownloadTextField.stringValue = "https://mp3.zing.vn/playlist/bai-hat-cua-Yiruma/IWZ9Z7F8.html?list=song_artist_play"
    }
    
    @IBAction func userClickedDownloadBtn(_ sender: Any) {
        print(linkDownloadTextField.stringValue)
        print(pathToSaveTextField.stringValue)

        if let url = URL(string: linkDownloadTextField.stringValue){
            DispatchQueue.global(qos: .background).async {
                self.list = ZingMp3Store.sharedInstance.getZingMp3SongList(listSongUrl: url) ?? [SongModel]()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                var counter    = 0
                
                for mp3 in self.list{
                    
                    DispatchQueue.global(qos: .background).async {
                        
                        let fileName   = mp3.title + ".mp3"
                        let pathToSave = self.pathToSaveTextField.stringValue
                        let folderUrl  = URL(fileURLWithPath: pathToSave).appendingPathComponent(fileName)
                        if FileManager.default.fileExists(atPath: folderUrl.path){
                            DispatchQueue.main.async {
                                self.list[counter].statusDownload = .exist
                                self.tableView.reloadData(forRowIndexes: IndexSet([counter]), columnIndexes: IndexSet([3]))
                                counter += 1
                            }
                            self.sema.signal()
                        }else{
                            DispatchQueue.main.async {
                                self.list[counter].statusDownload = .downloading
                                self.tableView.reloadData(forRowIndexes: IndexSet([counter]), columnIndexes: IndexSet([3]))
                            }
                            
                            let url        = self.list[counter].source128.replacingOccurrences(of: "//", with: "https://")

                            ZingMp3Store.sharedInstance.downloadMp3File(fileName: fileName, url: URL(string:   url)!, desinationPath: pathToSave, completion: { (success, error) in
                                DispatchQueue.main.async {
                                    counter += 1
                                    if counter == self.list.count {
                                        return;
                                    }
                                    self.list[counter].statusDownload = .downloaded
                                    self.tableView.reloadData(forRowIndexes: IndexSet([counter]), columnIndexes: IndexSet([3]))
                                }
                                self.sema.signal()

                            }, progressDownloaded: { (progress) in
                                DispatchQueue.main.async {
                                    self.list[counter].progressDownloaded = progress
                                    if (progress == 1.0){
                                        self.list[counter].statusDownload = .downloaded
                                    }
                                    self.tableView.reloadData(forRowIndexes: IndexSet([counter]), columnIndexes: IndexSet([2,3]))
                                }
                            })
                        }
                    }
                    self.sema.wait(timeout: DispatchTime.distantFuture)
                }
            }
        }
    }
    
    @IBAction func userClickedStopBtn(_ sender: Any) {
        self.sema.wait()
    }
    
    @IBAction func userClickedCheckBox(_ sender: Any) {
        
    }
    
    @IBAction func userClickedSelectPathBtn(_ sender: Any) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a folder file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                pathToSaveTextField.stringValue = path
            }
        } else {
            return
        }
    }
    
}


extension HomeViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    static let TITLE_CELL_ID    = "TitleCellID"
    static let PROGRESS_CELL_ID = "ProgressCellID"
    static let NUMBER_CELL_ID   = "NumberCellID"
    static let STATUS_CELL_ID   = "StatusCellID"
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellIdentifier = HomeViewController.NUMBER_CELL_ID
        var value          = ""
        
        if tableColumn     == tableView.tableColumns[0] {
            cellIdentifier = HomeViewController.NUMBER_CELL_ID
            value          = String(row + 1)
        }else if tableColumn  == tableView.tableColumns[1]{
            cellIdentifier = HomeViewController.TITLE_CELL_ID
            value          = list[row].title
        }else if tableColumn  == tableView.tableColumns[2]{
            cellIdentifier = HomeViewController.PROGRESS_CELL_ID
            value          = String(format: "%.3f", list[row].progressDownloaded * 100) + "%"
        }else{
            cellIdentifier = HomeViewController.STATUS_CELL_ID
            value          = self.list[row].statusDownload.rawValue
        }
        
        if let cell = tableView.makeView( withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = value

            return cell
        }
        return nil
    }
}

