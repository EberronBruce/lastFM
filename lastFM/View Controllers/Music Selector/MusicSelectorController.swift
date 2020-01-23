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
    
    private var musicInfoContainer = [SectionType : [MusicInfo]]()
    private var isApiFinished = true
    private var beforeSearch : String?
    private var afterSearch : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViewController()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupViewController() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(actOnApiCompleteNotification(_:)), name: API_NOTIFY, object: nil)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    
    
    @objc func actOnApiCompleteNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let isSafe = self.checkSearchAndMakeAPICallIfDifferent() else {
                print("Something serious happened. There is no search text")
                return
            }
            if isSafe {
                if let data = notification.userInfo as? [SectionType : [MusicInfo]] {
                    self.musicInfoContainer = data
                    self.tableView.reloadData()
                }
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

extension MusicSelectorController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //To prevent more that one API call at time which will help resolve race conditions
        beforeSearch = searchText
        if isApiFinished {
            makeAPICallForMusicInfoFrom(text: searchText)
            isApiFinished = false
            afterSearch = searchText
        }
    }
}


extension MusicSelectorController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return musicInfoContainer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MUSIC_CELL) as? MusicCell {
            let (title, subTitle) = configureCellInformation(indexPath: indexPath)
            cell.configureCell(title: title, subTitle: subTitle)
            return cell
        } else {
            return MusicCell()
        }
        
    }
    
    func configureCellInformation(indexPath: IndexPath) -> (title : String, subTitle : String) {
        var title : String = "No String"
        var subTitle : String = "No String"
        if let section = SectionType(rawValue: indexPath.section)
        {
            switch section {
            case .albums:
                if let albums = musicInfoContainer[.albums] {
                    let album = albums[indexPath.row]
                    title = album.album
                    subTitle = album.artist
                }
            case .tracks:
                if let tracks = musicInfoContainer[.tracks] {
                    let song = tracks[indexPath.row]
                    title = song.song
                    subTitle = song.artist
                }
            case .artist:
                if let artists = musicInfoContainer[.artist] {
                    let artist = artists[indexPath.row]
                    title = artist.artist
                    subTitle = artist.album
                }
            }
        }
        return (title, subTitle)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let musicType = SectionType(rawValue: section) {
            switch musicType {
            case .albums:
                if let albums = musicInfoContainer[.albums] {
                    return albums.count
                }
                return 0
            case .tracks:
                if let tracks =  musicInfoContainer[.tracks] {
                    return tracks.count
                }
                return 0
            case .artist:
                if let artists = musicInfoContainer[.artist] {
                    return artists.count
                }
                return 0
            }
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let tableSection = SectionType(rawValue: section) {
            switch tableSection {
            case .albums:
                return "Albums"
            case .artist:
                return "Artist"
            case .tracks:
                return "Songs"
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(displayP3Red: 0.314, green: 0.314, blue: 0.314, alpha: 1)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(displayP3Red: 0.725, green: 0.099, blue: 0.000, alpha: 1)
        header.textLabel?.font = UIFont(name: "Marker Felt", size: 20)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    

}



