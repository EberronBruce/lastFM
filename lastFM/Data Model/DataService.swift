//
//  DataService.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/22/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import Foundation



class DataService {
    
    private var musicInfoContainer = [Category : [MusicInfo]]()
        
    func getDataFromApiCalls(searchText : String){
        let text =  manipulateStringFor(searchText)
        makeAlbumCall(searchText: text)
        makeArtistCall(searchText: text)
        makeTrackCall(searchText: text)
    }

    private func makeArtistCall(searchText : String) {
        let url = ("\(BASE_URL)\(ARTIST_URL)\(searchText)\(API_KEY_URL)\(FORMAT_JSON_URL)")
        postJSONToURL(urlString: url, contentBody: [:]) { (data, response, error) in
            self.parseArtistData(response: response)
        }
    }
    
    private func makeAlbumCall(searchText : String) {
        let url = ("\(BASE_URL)\(ALBUM_URL)\(searchText)\(API_KEY_URL)\(FORMAT_JSON_URL)")
        postJSONToURL(urlString: url, contentBody: [:]) { (data, response, error) in
            self.parseAlbumData(response: response)
        }
 
    }
    
    private func makeTrackCall(searchText : String) {
        let url = ("\(BASE_URL)\(TRACK_URL)\(searchText)\(API_KEY_URL)\(FORMAT_JSON_URL)")
        postJSONToURL(urlString: url, contentBody: [:]) { (data, response, error) in
            self.parseTrackData(response: response)
        }
    }
    
    private func parseTrackData(response : [String : Any]) {
        var musicInfoArray : [MusicInfo] = []
        if let results = response[KEY_RESULTS] as? Dictionary<String, Any>, let trackmatches = results[KEY_TRACK_MATCHES] as? Dictionary<String,Any>, let tracks = trackmatches[KEY_TRACK] as? [Dictionary<String,Any>]{
            for track in tracks {
                if let trackInfo = self.extractInformation(info: track, category: .tracks) {
                    musicInfoArray.append(trackInfo)
                }
            }
        }
        musicInfoContainer[.tracks] = musicInfoArray
        sendOutMusicInfoNotification()
    }
    
    private func parseArtistData(response : [String : Any]) {
        var musicInfoArray : [MusicInfo] = []
        if let results = response[KEY_RESULTS] as? Dictionary<String, Any>, let artistmatches = results[KEY_ARTIST_MATCHES] as? Dictionary<String,Any>, let artists = artistmatches[KEY_ARTIST] as? [Dictionary<String,Any>]{
            for artist in artists {
                if let artistInfo = self.extractInformation(info: artist, category: .artist) {
                    musicInfoArray.append(artistInfo)
                }
            }
        }
        musicInfoContainer[.artist] = musicInfoArray
        sendOutMusicInfoNotification()
    }
    
    private func parseAlbumData(response : [String : Any]) {
        var musicInfoArray : [MusicInfo] = []
        if let results = response[KEY_RESULTS] as? Dictionary<String, Any>, let albummatches = results[KEY_ALBUM_MATCHES] as? Dictionary<String,Any>, let albums = albummatches[KEY_ALBUM] as? [Dictionary<String,Any>]{
            for album in albums {
                if let albumInfo = self.extractInformation(info: album, category: .albums) {
                    musicInfoArray.append(albumInfo)
                }
            }
        }
        musicInfoContainer[.albums] = musicInfoArray
        sendOutMusicInfoNotification()
    }
    
    private func extractInformation(info: Dictionary<String,Any>, category: Category) -> MusicInfo? {
        if let name = info[KEY_NAME] as? String, let url = info[KEY_URL] as? String {
            let artist = info[KEY_ARTIST] as? String

            if let imageLinks = info[KEY_IMAGE] as? [Dictionary<String,String>] {
                let imageLinkArray = self.parseImageUrls(imageLinks: imageLinks)
                let musicInfo = setupMusicInfo(category: category, name: name, url: url, artist: artist, imageUrlArray: imageLinkArray)
                return musicInfo
            }
            let musicInfo = setupMusicInfo(category: category, name: name, url: url, artist: artist)
            return musicInfo
        }
        return nil
    }
    
    private func setupMusicInfo(category : Category, name: String, url : String, artist : String? = nil, imageUrlArray : Dictionary<String,String>? = nil) -> MusicInfo? {
        var musicInfo : MusicInfo? = nil
        switch category {
        case .albums:
            if artist != nil {
                musicInfo = MusicInfo(artist: artist!, album: name, song: nil, category: category, url: url, imageUrls: imageUrlArray)
            }
            break
        case .artist:
            musicInfo = MusicInfo(artist: name, album: nil, song: nil, category: category, url: url, imageUrls: imageUrlArray)
            break
        case .tracks:
            if artist != nil {
                musicInfo = MusicInfo(artist: artist!, album: nil, song: name, category: category, url: url, imageUrls: imageUrlArray)
            }
            break
        }
        return musicInfo
    }
    
    private func parseImageUrls(imageLinks : [Dictionary<String,String>]) -> [String : String] {
        var imageUrlDict : [String : String] = [:]
        for link in imageLinks {
            if let imageUrl = link[KEY_NUMBER_TEXT], let imageSize = link[KEY_SIZE] {
                imageUrlDict[imageSize] = imageUrl
            }
        }
        return imageUrlDict
    }
    
    private func manipulateStringFor(_ searchText : String) -> String {
        var text = searchText
        text = replaceMultipleSpaceWithUnderline(searchText: text)
        text = text.replacingOccurrences(of: SPACE, with: CODE_HTTP_SPACE, options: .literal, range: nil)
        return text
    }
    
    private func replaceMultipleSpaceWithUnderline(searchText : String) -> String {
        let regex = REGX_DOUBLE_SPACE
        var modString = searchText
        if let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) {
            modString = regex.stringByReplacingMatches(in: searchText, options: [], range: NSRange(location: 0, length:  searchText.count), withTemplate: CODE_HTTP_SPACE)
        }
        return modString
    }
    
    private func sendOutMusicInfoNotification() {
        if(musicInfoContainer.count == MAX_API_CALLS) {
            NotificationCenter.default.post(name: API_NOTIFY, object: self, userInfo: musicInfoContainer)
        }
    }
    
    private func printMusicInfo(musicInfo : MusicInfo) {
        print("----------------------------")
        print(musicInfo.artist)
        print(musicInfo.album)
        print(musicInfo.url)
        print("+++++++++++++++++++++++++++")
        if let links = musicInfo.imageUrls {
            for (key, value) in links {
                print("Key: \(key), Value: \(value)")
            }
        }
        print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%")

        
    }
    
}
