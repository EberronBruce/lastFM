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
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var artistTabButton: UITabBarItem!
    @IBOutlet weak var albumsTabButton: UITabBarItem!
    @IBOutlet weak var songsTabButton: UITabBarItem!
    
    internal var musicInfoContainer = [MusicCategory : [MusicInfo]]()
    
    internal var infoContainer = [MusicInfo]()
    internal var imageRecords = [ImageRecord?]()
    internal var pageNumberDictionary = [MusicCategory : Int]()
    
    internal var isFetchingNewPage = false
    internal var allowForFetch = false
    internal var isApiFinished = true
    internal var beforeSearch : String?
    internal var afterSearch : String?
    internal var imageRecordsDictArray = [MusicCategory : [ImageRecord?]]()
    internal let pendingOperations = PendingOperations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupViewController() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tabBar.delegate = self
        artistTabButton.tag = MusicCategory.artist.rawValue
        albumsTabButton.tag = MusicCategory.albums.rawValue
        songsTabButton.tag = MusicCategory.tracks.rawValue
        tabBar.selectedItem = albumsTabButton
        NotificationCenter.default.addObserver(self, selector: #selector(actOnMusicDictonaryApiCompleteNotification(_:)), name: NOTIFY_API_MUSIC_DICT, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(actOnMusicArrayApiCompleteNotification(_:)), name: NOTIFY_API_MUSIC_ARRAY, object: nil)

    }
    
    internal func resetPageNumber() {
        if let items = tabBar.items {
            for item in items {
                if let category = MusicCategory(rawValue: item.tag) {
                    pageNumberDictionary[category] = 1
                }
            }
        }
    }

    @objc func actOnMusicDictonaryApiCompleteNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let isSafe = self.checkSearchAndMakeAPICallIfDifferent() else {
                return
            }
            if isSafe {
                if let data = notification.userInfo as? [MusicCategory : [MusicInfo]]{
                    self.musicInfoContainer = data
                    self.setContainerFromSelectTabBar(tabBar: self.tabBar)
                    
                    self.loadImageRecordData(musicInfoArray: self.infoContainer)
                    
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func actOnMusicArrayApiCompleteNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            if let data = notification.userInfo as? [String : [MusicInfo]], var musicArray = data[KEY_INFO_ARRAY] {
                if self.isFetchingNewPage {

                    //Uses this to fix an issue with the API calls and just only add the difference
                    for info in self.infoContainer {
                        for i in 0..<musicArray.count {
                            if info.url.elementsEqual(musicArray[i].url) {
                                musicArray.remove(at: i)
                                break
                            }
                        }
                    }
                    
                    self.infoContainer += musicArray
                    
                    if let category = self.getKeyFromTabBar() {
                        self.musicInfoContainer[category] = musicArray
                    }

                    self.loadImageRecordData(musicInfoArray: musicArray)
                    self.isFetchingNewPage = false
                }
            }
            self.tableView.reloadData()
        }
    }
    

    
    private func loadImageRecordData(musicInfoArray : [MusicInfo]) {
        for musicInfo in musicInfoArray {
            if let url = musicInfo.imageUrls![KEY_LARGE], !url.isEmpty {
                let imageRecord = ImageRecord(name: musicInfo.artist, url: URL(string: url)!)
                self.imageRecords.append(imageRecord)
            } else {
                self.imageRecords.append(nil)
            }
        }
    }
    
    
    //Func is used to prevent race conditions with web searches but keeps the search text up to date
    private func checkSearchAndMakeAPICallIfDifferent() -> Bool? {
        if let before = beforeSearch, let after = afterSearch{
            if before.elementsEqual(after) {
                isApiFinished = true
                return true
            } else {
                let pageNumber = 1
                self.makeAPICallForMusicInfoFrom(text: after, pageNumber: pageNumber)
                beforeSearch = afterSearch
            }
            return false
        }
        return nil
    }
    
    internal func makeAPICallForMusicInfoFrom(text : String, pageNumber: Int, musicCategory : MusicCategory? = nil) {
        let dataServices = DataService()
        if let category = musicCategory {
            switch category {
            case .albums:
                dataServices.getAlbumDataFromApiCall(searchText: text, pageNumber: pageNumber)
                return
            case .artist:
                dataServices.getArtistDataFromApiCall(searchText: text, pageNumber: pageNumber)
                return
            case .tracks:
                dataServices.getTrackDataFromApiCall(searchText: text, pageNumber: pageNumber)
                return
            }
        } else {
            dataServices.getDataFromApiCalls(searchText: text, pageNumber: pageNumber)
        }
        
    }
    
 
    
    internal func setContainerFromSelectTabBar(tabBar: UITabBar) {
        guard let tag = tabBar.selectedItem?.tag else {
            return
        }
        if let category = MusicCategory(rawValue: tag), let musicArray = musicInfoContainer[category] {
            infoContainer = musicArray
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_DETAIL_VIEW, let detailVC = segue.destination as? MusicDetailViewController {
            if let data = sender as?  [String: Any], let musicInfo = data[KEY_DATA] as? MusicInfo {
                detailVC.musicInfo = musicInfo
                if let image = data[KEY_IMAGE] as? UIImage {
                    detailVC.imageArray = [image]
                }
            }
        }
    }

}

//MARK: - Search Bar Delegates Methods
extension MusicSelectorController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.resetPageNumber()
        isFetchingNewPage = false
        let pageNumber = 1
        //To prevent more that one API call at time which will help resolve race conditions
        beforeSearch = searchText
        if isApiFinished {
            makeAPICallForMusicInfoFrom(text: searchText, pageNumber: pageNumber)
            isApiFinished = false
            afterSearch = searchText
        }
        
        if searchText.isEmpty {
            clearContainersAndReload()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    private func clearContainersAndReload() {
        musicInfoContainer = [:]
        infoContainer = []
        imageRecords = []
        self.tableView.reloadData()
    }
}

extension MusicSelectorController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let category = MusicCategory(rawValue: item.tag), let musicArray = musicInfoContainer[category] {
            self.infoContainer = musicArray
        }
        imageRecords = []
        loadImageRecordData(musicInfoArray: infoContainer)
        isFetchingNewPage = false
        
        scrollTableViewToTop()
        self.tableView.reloadData()
    }
}


