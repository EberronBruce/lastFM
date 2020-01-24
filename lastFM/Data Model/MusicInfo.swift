//
//  MusicInfo.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/21/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit

enum Category : Int {
    case albums, artist, tracks
    
    static let count: Int = {
        var max: Int = 0
        while let _ = Category(rawValue: max) {max += 1}
        return max
    }()
}

class MusicInfo {
    private var _artist: String!
    private var _album: String?
    private var _song: String?
    private var _mediumImage: UIImage?
    private var _imageArray: [UIImage]?
    private var _url : String!
    private var _category : Category!
    private var _imageUrls : Dictionary<String,String>?
    
    init(artist: String, album : String? = nil, song : String? = nil, category : Category, url : String, imageUrls : Dictionary<String,String>? = nil) {
        _artist = artist
        _album = album
        _song = song
        _category = category
        _url = url
        _imageUrls = imageUrls
    }
    
    var imageUrls : Dictionary<String,String>? {
        get {
            return _imageUrls ?? nil
        }
    }
    
    var category : Category {
        get {
            return _category
        }
    }
    
    var artist : String {
        get {
          return _artist
        }
    }
    
    var album : String {
        get {
            return _album ?? EMPTY
        }
    }
    
    var song : String {
        get {
           return _song ?? EMPTY
        }
    }
    
    var url : String {
        get {
            return _url 
        }
    }
    
    var mediumImage: UIImage? {
        set{
            _mediumImage = newValue
        }
        get {
            return _mediumImage ?? nil
        }
    }
    
    var imageArray : [UIImage]? {
        set {
            _imageArray = newValue
        }
        get {
            return _imageArray ?? nil
        }
    }

}
