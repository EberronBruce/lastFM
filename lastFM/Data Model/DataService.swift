//
//  DataService.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/22/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import Foundation

enum SectionType: Int {
    case albums, artist, tracks
}

class DataService {
    
    private var musicInfoContainer = [SectionType : [MusicInfo]]()
    
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
        if let results = response[RESULTS_KEY] as? Dictionary<String, Any>, let trackmatches = results[TRACK_MATCHES_KEY] as? Dictionary<String,Any>, let tracks = trackmatches[TRACK_KEY] as? [Dictionary<String,Any>]{
            for track in tracks {
                if let trackInfo = self.extractInformation(info: track, sectionType: .tracks) {
                    musicInfoArray.append(trackInfo)
                }
            }
        }
        musicInfoContainer[.tracks] = musicInfoArray
    }
    
    private func parseArtistData(response : [String : Any]) {
        var musicInfoArray : [MusicInfo] = []
        if let results = response[RESULTS_KEY] as? Dictionary<String, Any>, let artistmatches = results[ARTIST_MATCHES_KEY] as? Dictionary<String,Any>, let artists = artistmatches[ARTIST_KEY] as? [Dictionary<String,Any>]{
            for artist in artists {
                if let artistInfo = self.extractInformation(info: artist, sectionType: .artist) {
                    musicInfoArray.append(artistInfo)
                }
            }
        }
        musicInfoContainer[.artist] = musicInfoArray
    }
    
    private func parseAlbumData(response : [String : Any]) {
           var musicInfoArray : [MusicInfo] = []
           if let results = response[RESULTS_KEY] as? Dictionary<String, Any>, let albummatches = results[ALBUM_MATCHES_KEY] as? Dictionary<String,Any>, let albums = albummatches[ALBUM_KEY] as? [Dictionary<String,Any>]{
               for album in albums {
                   if let albumInfo = self.extractInformation(info: album, sectionType: .albums) {
                       musicInfoArray.append(albumInfo)
                   }
               }
           }
           musicInfoContainer[.albums] = musicInfoArray
       }
    
    private func extractInformation(info: Dictionary<String,Any>, sectionType: SectionType) -> MusicInfo? {
        if let name = info[NAME_KEY] as? String, let url = info[URL_KEY] as? String {
            
            let artist = info[ARTIST_KEY] as? String

            if let imageLinks = info[IMAGE_KEY] as? [Dictionary<String,String>] {
                let imageLinkArray = self.parseImageUrls(imageLinks: imageLinks)
                let musicInfo = setupMusicInfo(sectionType: sectionType, name: name, url: url, artist: artist, imageUrlArray: imageLinkArray)
                return musicInfo
            }
            let musicInfo = setupMusicInfo(sectionType: sectionType, name: name, url: url, artist: artist)
            return musicInfo
        }
        return nil
    }
    
    private func setupMusicInfo(sectionType : SectionType, name: String, url : String, artist : String? = nil, imageUrlArray : [String]? = nil) -> MusicInfo? {
         var musicInfo : MusicInfo? = nil
        switch sectionType {
        case .albums:
            if artist != nil {
                musicInfo = MusicInfo(artist: artist!, album: name, song: nil, type: sectionType, url: url, imageUrls: imageUrlArray)
            }
            break
        case .artist:
            musicInfo = MusicInfo(artist: name, album: nil, song: nil, type: sectionType, url: url, imageUrls: imageUrlArray)
            break
        case .tracks:
            if artist != nil {
                musicInfo = MusicInfo(artist: artist!, album: nil, song: name, type: sectionType, url: url, imageUrls: imageUrlArray)
            }
            break
        }
        return musicInfo
    }
    
    private func parseImageUrls(imageLinks : [Dictionary<String,String>]) -> [String] {
        var imageUrlArray : [String] = []
        for link in imageLinks {
            if let imageUrl = link["#text"] {
                imageUrlArray.append(imageUrl)
            }
        }
        return imageUrlArray
    }
    
    private func manipulateStringFor(_ searchText : String) -> String {
        var text = searchText
        text = replaceMultipleSpaceWithUnderline(searchText: text)
        text = text.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        return text
    }
    
    private func replaceMultipleSpaceWithUnderline(searchText : String) -> String {
        let regex = "(\\s{2,})"
        var modString = searchText
        if let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) {
            modString = regex.stringByReplacingMatches(in: searchText, options: [], range: NSRange(location: 0, length:  searchText.count), withTemplate: "%20")
        }
        return modString
    }
    

    
}
