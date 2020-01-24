//
//  ViewController.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/20/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit

class MusicSelectorController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var musicInfoContainer = [Category : [MusicInfo]]()
    private var isApiFinished = true
    private var beforeSearch : String?
    private var afterSearch : String?
    private var imageRecordsDictArray = [Category : [ImageRecord?]]()
    let pendingOperations = PendingOperations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViewController()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    private func setupViewController() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(actOnApiCompleteNotification(_:)), name: API_NOTIFY, object: nil)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    private func startOperationForImageRecord(imageRecord : ImageRecord, indexPath : IndexPath) {
        switch imageRecord.state {
        case .New:
            startDownload(imageRecord: imageRecord, indexPath: indexPath)
        case .Downloaded:
            //print("Image Downloaded")
            break
        case .Failed:
            //print("Image Download Failed")
            break
        }
    }
    
    
    private func startDownload(imageRecord : ImageRecord, indexPath: IndexPath) {
        if pendingOperations.downloadsInProgress[indexPath] != nil {
            return
        }
        
        let downloader = ImageDownloader(imageRecord: imageRecord)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    
    
    
    @objc func actOnApiCompleteNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let isSafe = self.checkSearchAndMakeAPICallIfDifferent() else {
                return
            }
            if isSafe {
                if let data = notification.userInfo as? [Category : [MusicInfo]] {
                    self.musicInfoContainer = data
                    self.loadImageRecordData()
                }
                self.tableView.reloadData()
            }
        }
    }
    
    private func loadImageRecordData() {
        for (key, musicInfoArray) in self.musicInfoContainer {
            var imageRecords = [ImageRecord?]()
            for music in musicInfoArray {
                if let url = music.imageUrls![KEY_LARGE], !url.isEmpty  {
                    let imageRecord = ImageRecord(name: music.artist, url: URL(string: url)!)
                    imageRecords.append(imageRecord)
                } else {
                    imageRecords.append(nil)
                }
            }
            self.imageRecordsDictArray[key] = imageRecords
        }
    }
    
    //Func is used to prevent race conditions with web searches but keeps the search text up to date
    private func checkSearchAndMakeAPICallIfDifferent() -> Bool? {
        if let before = beforeSearch, let after = afterSearch{
            if before.elementsEqual(after) {
                isApiFinished = true
                return true
            } else {
                self.makeAPICallForMusicInfoFrom(text: after)
                beforeSearch = afterSearch
            }
            return false
        }
        return nil
    }
    
    private func makeAPICallForMusicInfoFrom(text : String) {
        let dataServices = DataService()
        dataServices.getDataFromApiCalls(searchText: text)
    }

}

//MARK: - Search Bar Delegates Methods
extension MusicSelectorController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //To prevent more that one API call at time which will help resolve race conditions
        beforeSearch = searchText
        if isApiFinished {
            makeAPICallForMusicInfoFrom(text: searchText)
            isApiFinished = false
            afterSearch = searchText
        }
        
        if searchText.isEmpty {
            musicInfoContainer = [:]
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}

//MARK: - TableView Delegates and Datasource Methods
extension MusicSelectorController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Category.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MUSIC_CELL) as? MusicCell {
            let (title, subTitle) = configureCellInformation(indexPath: indexPath)
            cell.configureCell(title: title, subTitle: subTitle)
            
            if let musicInfo = getSectionMusicInfo(indexPath: indexPath), let imageRecordArray = imageRecordsDictArray[musicInfo.category]  {
                let imageRecord = imageRecordArray[indexPath.row]
                
                if let image = imageRecord?.image {
                    cell.updateCellImage(image: image)
                } else {
                    if let defaultImage = UIImage(named: IMAGE_LOGO) {
                        cell.updateCellImage(image: defaultImage)
                    }
                   
                }
                getImageFrom(imageRecord: imageRecord, indexPath: indexPath)
            }
            
            return cell
        } else {
            return MusicCell()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let musicType = Category(rawValue: section) {
            switch musicType {
            case .albums:
                if let albums = musicInfoContainer[.albums] {
                    return albums.count
                }
            case .tracks:
                if let tracks =  musicInfoContainer[.tracks] {
                    return tracks.count
                }
            case .artist:
                if let artists = musicInfoContainer[.artist] {
                    return artists.count
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let tableSection = Category(rawValue: section) {
            switch tableSection {
            case .albums:
                return SECTION_TITLE_ALBUMS
            case .artist:
                return SECTION_TITLE_ARTISTS
            case .tracks:
                return SECTION_TITLE_SONGS
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = COLOR_THEME_GRAY
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = COLOR_THEME_RED
        header.textLabel?.font = UIFont(name: FONT_MARKER_FELT, size: 20)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO - Work on Transition here

    }
}


//MARK: - Methods Used In TableView Delegates and Datasources
extension MusicSelectorController {
    func getImageFrom(imageRecord : ImageRecord?, indexPath : IndexPath) {
        if let state = imageRecord?.state, let record = imageRecord {
            switch state {
            case .Failed: break
            case .New, .Downloaded:
                self.startOperationForImageRecord(imageRecord: record, indexPath: indexPath)
            }
        }
    }
    
    func configureCellInformation(indexPath: IndexPath) -> (title : String, subTitle : String) {
        var title : String = EMPTY
        var subTitle : String = EMPTY
        if let section = Category(rawValue: indexPath.section)
        {
            switch section {
            case .albums:
                if let album = getSectionMusicInfo(indexPath: indexPath){
                    title = album.album
                    subTitle = album.artist
                }
                
            case .tracks:
                if let song = getSectionMusicInfo(indexPath: indexPath) {
                    title = song.song
                    subTitle = song.artist
                }
            case .artist:
                if let artist = getSectionMusicInfo(indexPath: indexPath) {
                    title = artist.artist
                    subTitle = artist.album
                }
            }
        }
        return (title, subTitle)
    }
    
    private func getSectionMusicInfo(indexPath: IndexPath) -> MusicInfo? {
        if let section = Category(rawValue: indexPath.section)
        {
            switch section {
            case .albums:
                if let albums = musicInfoContainer[.albums] {
                    let album = albums[indexPath.row]
                    return album
                }
            case .tracks:
                if let tracks = musicInfoContainer[.tracks] {
                    let song = tracks[indexPath.row]
                    return song
                }
            case .artist:
                if let artists = musicInfoContainer[.artist] {
                    let artist = artists[indexPath.row]
                    return artist
                }
            }
        }
        return nil
    }
}

