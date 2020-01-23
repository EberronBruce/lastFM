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
    

    
    var albumInfo : [MusicInfo] = []
    var artistInfo : [MusicInfo] = []
    var songInfo : [MusicInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        generateMusicTestInfo()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func generateMusicTestInfo() {
        var info = MusicInfo(artist: "Artist 1", album: "Album 1", song: "Song 1", type: .albums, url: "url1")
        albumInfo.append(info)
        info = MusicInfo(artist: "Artist 1", album: "Album 2", song: "Song 1", type: .albums, url: "url1")
        albumInfo.append(info)
        info = MusicInfo(artist: "Artist 1", album: "Album 3", song: "Song 1", type: .albums, url: "url1")
        albumInfo.append(info)
        info = MusicInfo(artist: "Artist 1", album: "Album 4", song: "Song 1", type: .albums, url: "url1")
        albumInfo.append(info)
        
        info = MusicInfo(artist: "Artist 1", album: "Album 1", song: "Song 1", type: .artist, url: "url1")
        artistInfo.append(info)
        info = MusicInfo(artist: "Artist 2", album: "Album 1", song: "Song 1", type: .artist, url: "url1")
        artistInfo.append(info)
        info = MusicInfo(artist: "Artist 3", album: "Album 1", song: "Song 1", type: .artist, url: "url1")
        artistInfo.append(info)
        
        info = MusicInfo(artist: "Artist 1", album: "Album 1", song: "Song 1", type: .artist, url: "url1")
        songInfo.append(info)
        info = MusicInfo(artist: "Artist 1", album: "Album 1", song: "Song 2", type: .artist, url: "url1")
        songInfo.append(info)
        info = MusicInfo(artist: "Artist 1", album: "Album 1", song: "Song 3", type: .artist, url: "url1")
        songInfo.append(info)
        info = MusicInfo(artist: "Artist 1", album: "Album 1", song: "Song 4", type: .artist, url: "url1")
        songInfo.append(info)
    }
    
    
}

extension MusicSelectorController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        let dataServices = DataService()
        dataServices.getDataFromApiCalls(searchText: searchText)

    }
        
}


extension MusicSelectorController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MUSIC_CELL) as? MusicCell {
            var title : String = "No String"
            var subTitle : String = "No String"
            if let section = SectionType(rawValue: indexPath.section)
            {
                switch section {
                case .albums:
                    let album = albumInfo[indexPath.row]
                    title = album.album
                    subTitle = album.artist
                case .tracks:
                    let song = songInfo[indexPath.row]
                    title = song.song
                    subTitle = song.artist
                case .artist:
                    let artist = artistInfo[indexPath.row]
                    title = artist.artist
                    subTitle = artist.album
                }
            }
            cell.configureCell(title: title, subTitle: subTitle)
            return cell
        } else {
            return MusicCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let musicType = SectionType(rawValue: section) {
            switch musicType {
            case .albums:
                return albumInfo.count
            case .tracks:
                return songInfo.count
            case .artist:
                return artistInfo.count
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



