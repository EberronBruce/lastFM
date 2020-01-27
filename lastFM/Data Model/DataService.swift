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

/*
 This Class is responsible for making API calls to the server to get information and parse that information.
 */

class DataService {
    
    private var musicInfoContainer = [MusicCategory : [MusicInfo]]()
    private var imageContainer = [UIImage]()
    private var isSingleCall = false
    
    //This function makes all calls to get all data at the same time.
    func getDataFromApiCalls(searchText : String, pageNumber : Int = 1){
        let text =  manipulateStringFor(searchText)
        makeAlbumCall(searchText: text, pageNumber: pageNumber)
        makeArtistCall(searchText: text, pageNumber: pageNumber)
        makeTrackCall(searchText: text, pageNumber: pageNumber)
    }
    //Used to just get Artist information
    func getArtistDataFromApiCall(searchText : String, pageNumber : Int = 1) {
        isSingleCall = true
        let text =  manipulateStringFor(searchText)
        makeArtistCall(searchText: text, pageNumber: pageNumber)
    }
    //Used to just get Album information
    func getAlbumDataFromApiCall(searchText : String, pageNumber : Int = 1) {
        isSingleCall = true
        let text =  manipulateStringFor(searchText)
        makeAlbumCall(searchText: text, pageNumber: pageNumber)
    }
    //Used to just get track information
    func getTrackDataFromApiCall(searchText : String, pageNumber : Int = 1) {
        isSingleCall = true
        let text =  manipulateStringFor(searchText)
        makeTrackCall(searchText: text, pageNumber: pageNumber)
    }
    //Use to get the image from an image url. if nothing. Set to default image.
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
    //This is to get the detail information fo the artist.
    func getArtistDetailsFromApiCall(_ artist: String) {
        let text =  manipulateStringFor(artist)
        makeArtistCall(artist: text)
    }
    //Makes the call to get detail information of the artinst.
    private func makeArtistCall(artist: String) {
        let url = "\(URL_BASE)\(URL_ARTIST_INFO)\(artist)\(URL_API_KEY)\(URL_FORMAT_JSON)"
        postJSONToURL(urlString: url, contentBody: [:]) { (data, response, error) in
            self.parseArtistInformation(response: response)
        }
    }
    //Gets the bio link for the artist. Used for webview with details.
    private func parseArtistInformation(response : [String : Any]) {
        if let artist = response[KEY_ARTIST] as? Dictionary<String, Any>, let bio = artist[KEY_BIO] as? Dictionary<String, Any>, let links = bio[KEY_LINKS] as? Dictionary<String, Any>, let link = links[KEY_LINK] as? Dictionary<String, Any> {
            if let href = link[KEY_HREF] as? String {
                sendArtistInfoLink(link: href)
            }
        }
    }
    //Makes the artist url call
    private func makeArtistCall(searchText : String, pageNumber: Int, limitNumber: Int = NUMBER_LIMIT) {
        let url = ("\(URL_BASE)\(URL_ARTIST)\(searchText)\(URL_API_KEY)\(URL_FORMAT_JSON)\(URL_LIMIT)\(limitNumber)\(URL_PAGE)\(pageNumber)")
        postJSONToURL(urlString: url, contentBody: [:]) { (data, response, error) in
            self.parseArtistData(response: response)
        }
    }
    //Makes the album url call
    private func makeAlbumCall(searchText : String, pageNumber: Int, limitNumber: Int = NUMBER_LIMIT) {
        let url = ("\(URL_BASE)\(URL_ALBUM)\(searchText)\(URL_API_KEY)\(URL_FORMAT_JSON)\(URL_LIMIT)\(limitNumber)\(URL_PAGE)\(pageNumber)")
        postJSONToURL(urlString: url, contentBody: [:]) { (data, response, error) in
            self.parseAlbumData(response: response)
        }
 
    }
    //Makes the track url call
    private func makeTrackCall(searchText : String, pageNumber: Int, limitNumber: Int = (NUMBER_LIMIT)) {
        let url = ("\(URL_BASE)\(URL_TRACK)\(searchText)\(URL_API_KEY)\(URL_FORMAT_JSON)\(URL_LIMIT)\(limitNumber)\(URL_PAGE)\(pageNumber)")
        postJSONToURL(urlString: url, contentBody: [:]) { (data, response, error) in
            self.parseTrackData(response: response)
        }
    }
    //Parses out track information and sends it to be send out
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
    //Parses out Artist information and sends it to be send out
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
    //Parses out ablbum information and sends it to be send out
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
    
    //Extracts the information from the parsing. Then returns it as the MusicInfo object.
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
    
    //Sets up the MusicInfo class by Music Category.
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
    
    //Pares out image urls based on the size key
    private func parseImageUrls(imageLinks : [Dictionary<String,String>]) -> [String : String] {
        var imageUrlDict : [String : String] = [:]
        for link in imageLinks {
            if let imageUrl = link[KEY_NUMBER_TEXT], let imageSize = link[KEY_SIZE] {
                imageUrlDict[imageSize] = imageUrl
            }
        }
        return imageUrlDict
    }
    
    //Manipulates the string to make sure space is replaced the the http code for API calls.
    private func manipulateStringFor(_ searchText : String) -> String {
        var text = searchText
        text = replaceMultipleSpaceWithUnderline(searchText: text)
        text = text.replacingOccurrences(of: STRING_SPACE, with: CODE_HTTP_SPACE, options: .literal, range: nil)
        return text
    }
    
    //Checks for more than one space, replaces it with http space code.
    private func replaceMultipleSpaceWithUnderline(searchText : String) -> String {
        let regex = REGX_DOUBLE_SPACE
        var modString = searchText
        if let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) {
            modString = regex.stringByReplacingMatches(in: searchText, options: [], range: NSRange(location: 0, length:  searchText.count), withTemplate: CODE_HTTP_SPACE)
        }
        return modString
    }
    //Sends out the base notification to updating the tableview
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
    //Sends out the UI image back.
    private func sendOutImage(_ image : UIImage = UIImage(named: IMAGE_LOGO) ?? UIImage()) {
        let dictionary = [KEY_IMAGE_GET : image]
        NotificationCenter.default.post(name: NOTIFY_API_IMAGE, object: self, userInfo: dictionary)
    }
    //Sens back the artist url for the bio
    private func sendArtistInfoLink(link: String) {
        let dictionary = [KEY_ARTIST : link]
        NotificationCenter.default.post(name: NOTIFY_API_ARTIST, object: self, userInfo: dictionary)
    }
    
}
