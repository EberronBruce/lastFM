//
//  DataService.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/22/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit
/* NOTE: There are several issues with the API call and it sometimes sends back wrong data.
 Confirmed it with Postman and a web browser.
 To re-duplicate an example follow steps:
 Make api call to artist setting artist of 'R' page 6 limit 1, or limit 6 page 1.
 There will be only 3 items return back instead of 6.
 This error is beyond my control
 */


class DataService {
    
    private var musicInfoContainer = [MusicCategory : [MusicInfo]]()
    private var imageContainer = [UIImage]()
    private var isSingleCall = false
        
    func getDataFromApiCalls(searchText : String, pageNumber : Int = 1){
        let text =  manipulateStringFor(searchText)
        makeAlbumCall(searchText: text, pageNumber: pageNumber)
        makeArtistCall(searchText: text, pageNumber: pageNumber)
        makeTrackCall(searchText: text, pageNumber: pageNumber)
    }
    
    func getArtistDataFromApiCall(searchText : String, pageNumber : Int = 1) {
        isSingleCall = true
        let text =  manipulateStringFor(searchText)
        makeArtistCall(searchText: text, pageNumber: pageNumber)
    }
    
    func getAlbumDataFromApiCall(searchText : String, pageNumber : Int = 1) {
        isSingleCall = true
        let text =  manipulateStringFor(searchText)
        makeAlbumCall(searchText: text, pageNumber: pageNumber)
    }
    
    func getTrackDataFromApiCall(searchText : String, pageNumber : Int = 1) {
        isSingleCall = true
        let text =  manipulateStringFor(searchText)
        makeTrackCall(searchText: text, pageNumber: pageNumber)
    }
    
    func makeImageCallFrom(url urlString : String,  completionHandler: @escaping (_ image: UIImage? , _ error: Error?) -> Void) {
        getDataFromURL(urlString: urlString) { (data, error) in
            var image : UIImage? = nil
            if data != nil, let dataImage = UIImage(data: data!) {
                image = dataImage
            } else {
                if let imageLogo = UIImage(named: IMAGE_LOGO) {
                    image = imageLogo
                }
            }
            completionHandler(image, error)
        }
    }
    
    func getArtistDetailsFromApiCall(_ artist: String) {
        print("Artist Details: \(artist)")
        let text =  manipulateStringFor(artist)
        makeArtistCall(artist: text)
    }
    
    private func makeArtistCall(artist: String) {
        let url = "\(URL_BASE)\(URL_ARTIST_INFO)\(artist)\(URL_API_KEY)\(URL_FORMAT_JSON)"
        postJSONToURL(urlString: url, contentBody: [:]) { (data, response, error) in
            self.parseArtistInformation(response: response)
        }
    }
    
    private func parseArtistInformation(response : [String : Any]) {
        print("Response: \(response)")
        if let artist = response[KEY_ARTIST] as? Dictionary<String, Any>, let bio = artist[KEY_BIO] as? Dictionary<String, Any>, let links = bio[KEY_LINKS] as? Dictionary<String, Any>, let link = links[KEY_LINK] as? Dictionary<String, Any> {
            if let href = link[KEY_HREF] as? String {
                sendArtistInfoLink(link: href)
            }
        }
    }
    
    private func makeArtistCall(searchText : String, pageNumber: Int, limitNumber: Int = NUMBER_LIMIT) {
        let url = ("\(URL_BASE)\(URL_ARTIST)\(searchText)\(URL_API_KEY)\(URL_FORMAT_JSON)\(URL_LIMIT)\(limitNumber)\(URL_PAGE)\(pageNumber)")
        postJSONToURL(urlString: url, contentBody: [:]) { (data, response, error) in
            self.parseArtistData(response: response)
        }
    }
    
    private func makeAlbumCall(searchText : String, pageNumber: Int, limitNumber: Int = NUMBER_LIMIT) {
        let url = ("\(URL_BASE)\(URL_ALBUM)\(searchText)\(URL_API_KEY)\(URL_FORMAT_JSON)\(URL_LIMIT)\(limitNumber)\(URL_PAGE)\(pageNumber)")
        postJSONToURL(urlString: url, contentBody: [:]) { (data, response, error) in
            self.parseAlbumData(response: response)
        }
 
    }
    
    private func makeTrackCall(searchText : String, pageNumber: Int, limitNumber: Int = (NUMBER_LIMIT)) {
        let url = ("\(URL_BASE)\(URL_TRACK)\(searchText)\(URL_API_KEY)\(URL_FORMAT_JSON)\(URL_LIMIT)\(limitNumber)\(URL_PAGE)\(pageNumber)")
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
        sendOutMusicInfoNotification(forArray: musicInfoArray)
        
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
        sendOutMusicInfoNotification(forArray: musicInfoArray)
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
        sendOutMusicInfoNotification(forArray: musicInfoArray)

    }
    
    private func extractInformation(info: Dictionary<String,Any>, category: MusicCategory) -> MusicInfo? {
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
    
    private func setupMusicInfo(category : MusicCategory, name: String, url : String, artist : String? = nil, imageUrlArray : Dictionary<String,String>? = nil) -> MusicInfo? {
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
        text = text.replacingOccurrences(of: STRING_SPACE, with: CODE_HTTP_SPACE, options: .literal, range: nil)
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
    
    private func sendOutMusicInfoNotification(forArray musicArray: [MusicInfo]) {
        if isSingleCall {
            let dictionary = [KEY_INFO_ARRAY : musicArray]
            NotificationCenter.default.post(name: NOTIFY_API_MUSIC_ARRAY, object: self, userInfo: dictionary)
            return
        }
        if musicInfoContainer.count == MAX_API_CALLS {
            NotificationCenter.default.post(name: NOTIFY_API_MUSIC_DICT, object: self, userInfo: musicInfoContainer)
        }
    }
    
    private func sendOutImage(_ image : UIImage = UIImage(named: IMAGE_LOGO) ?? UIImage()) {
        let dictionary = [KEY_IMAGE_GET : image]
        NotificationCenter.default.post(name: NOTIFY_API_IMAGE, object: self, userInfo: dictionary)
    }
    
    private func sendArtistInfoLink(link: String) {
        let dictionary = [KEY_ARTIST : link]
        NotificationCenter.default.post(name: NOTIFY_API_ARTIST, object: self, userInfo: dictionary)
    }
    
    
}
