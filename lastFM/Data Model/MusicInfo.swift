//
//  MusicInfo.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/21/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit

class MusicInfo {
    private var _artist: String!
    private var _album: String?
    private var _song: String?
    private var _image: UIImage?
    private var _url : String!
    private var _type : SectionType!
    private var imageUrls : [String]?
    
    init(artist: String, album : String? = nil, song : String? = nil, type : SectionType, url : String, imageUrls : [String]? = nil) {
        _artist = artist
        _album = album
        _song = song
        _type = type
        _url = url
        self.imageUrls = imageUrls
    }
    
    var artist : String {
        get {
            if let artist = _artist {
                return artist
            }
            return ""
        }
    }
    
    var album : String {
        get {
            if let album = _album {
                return album
            }
            return ""
        }
    }
    
    var song : String {
        get {
            if let song = _song {
                return song
            }
            return ""
        }
    }
    
    var url : String {
           get {
               if let url = _url {
                   return url
               }
               return ""
           }
       }
    
    var image: UIImage? {
        set{
            _image = newValue
        }
        get {
            if _image != nil {
                return _image
            } else{
                return nil
            }
        }
    }
    
    func addImageLink(url : String) {
        imageUrls?.append(url)
    }
}
