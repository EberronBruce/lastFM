//
//  Constants.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/21/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import Foundation

let BASE_URL = "http://ws.audioscrobbler.com/2.0/"
let ALBUM_URL = "?method=album.search&album="
let ARTIST_URL = "?method=artist.search&artist="
let TRACK_URL = "?method=track.search&track="
let FORMAT_JSON_URL = "&format=json"
let API_KEY_URL = "&api_key=27939c41a4d5e9db202b2036c5bc12df"
let SECERT_KEY = "d59e4e5f555604aa476e83202bef1ee6"

let MUSIC_CELL = "musicCell"
let MUSIC_IMAGE_CELL = "musicImageCell"

let API_NOTIFY = Notification.Name("api.notify.complete")

let RESULTS_KEY = "results"
let TRACK_MATCHES_KEY = "trackmatches"
let TRACK_KEY = "track"
let ARTIST_MATCHES_KEY = "artistmatches"
let ARTIST_KEY = "artist"
let ALBUM_MATCHES_KEY = "albummatches"
let ALBUM_KEY = "album"
let NAME_KEY = "name"
let URL_KEY = "url"
let IMAGE_KEY = "image"
let NUMBER_TEXT_KEY = "#text"
let HTTP_SPACE_CODE = "%20"
let SPACE = " "
let DOUBLE_SPACE_REGX = "(\\s{2,})"
let MAX_API_CALLS = 3
