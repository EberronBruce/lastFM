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
    
    func getDataFromApiCalls(searchText : String){
        let text =  manipulateStringFor(searchText)
        print(text)
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
        print(url)
        postJSONToURL(urlString: url, contentBody: [:]) { (data, response, error) in
            self.parseTrackData(response: response)
        }
    }
    
    private func parseTrackData(response : [String : Any]) {
        var musicInfoArray : [MusicInfo] = []
        if let results = response["results"] as? Dictionary<String, Any>, let trackmatches = results["trackmatches"] as? Dictionary<String,Any>, let tracks = trackmatches["track"] as? [Dictionary<String,Any>]{
            for track in tracks {
                print("-----------------------")
                let name = track["name"] as! String
                let artist = track["artist"] as! String
                let url = track["url"] as! String
                let imageLinks = track["image"] as! [Dictionary<String,String>]
                for link in imageLinks {
                    print(link)
                }
                print(name)
                print(url)
                print(artist)
                print("***********************")
            }
        }
    }
    
    private func parseArtistData(response : [String : Any]) {
        var musicInfoArray : [MusicInfo] = []
        if let results = response["results"] as? Dictionary<String, Any>, let artistmatches = results["artistmatches"] as? Dictionary<String,Any>, let artists = artistmatches["artist"] as? [Dictionary<String,Any>]{
            for artist in artists {
//                 print("----------------------")
                //print(artist)
                let name = artist["name"] as! String
                let url = artist["url"] as! String
                let imageLinks = artist["image"] as! [Dictionary<String,String>]
                for link in imageLinks {
                    //print(link)
                }
//                print(name)
//                print(url)
//                print("***********************")
            }
            
            
        }
    }

    
    
    private func parseAlbumData(response : [String : Any]) {
        var musicInfoArray : [MusicInfo] = []
        if let results = response["results"] as? Dictionary<String, Any>, let albummatches = results["albummatches"] as? Dictionary<String,Any>, let albums = albummatches["album"] as? [Dictionary<String,Any>]{
            for album in albums {
               // print("----------------------")
                let artist = album["artist"] as! String
                let name = album["name"] as! String
                let url = album["url"] as! String
                let imageLinks = album["image"] as! [Dictionary<String,String>]
                for link in imageLinks {
                   // print(link)
                }
               
//                print(album["artist"] as! String)
//                print(album["name"] as! String)
//                print(album["url"] as! String)
//                print(album["image"] as! [Dictionary<String,String>])
               // print("***********************")
            }
        }
        
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
