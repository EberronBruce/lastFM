//
//  Constants.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/21/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit

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


let DOWNLOAD_QUEUE = "Download queue"
let IMAGE_OPERATION_DOWNLOAD_ERROR = "Issue with image Data"

let KEY_RESULTS = "results"
let KEY_TRACK_MATCHES = "trackmatches"
let KEY_TRACK = "track"
let KEY_ARTIST_MATCHES = "artistmatches"
let KEY_ARTIST = "artist"
let KEY_ALBUM_MATCHES = "albummatches"
let KEY_ALBUM = "album"
let KEY_NAME = "name"
let KEY_URL = "url"
let KEY_IMAGE = "image"
let KEY_NUMBER_TEXT = "#text"
let CODE_HTTP_SPACE = "%20"
let SPACE = " "
let EMPTY = ""

let REGX_DOUBLE_SPACE = "(\\s{2,})"
let MAX_API_CALLS = 3
let KEY_SIZE = "size"
let KEY_SMALL = "small"
let KEY_MEDIUM = "medium"
let KEY_LARGE = "large"
let KEY_EXTRA_LARGE = "extralarge"

let IMAGE_LOGO = "logo"

let COLOR_THEME_GRAY = UIColor(displayP3Red: 0.314, green: 0.314, blue: 0.314, alpha: 1)
let COLOR_THEME_RED = UIColor(displayP3Red: 0.725, green: 0.099, blue: 0.000, alpha: 1)
let FONT_MARKER_FELT = "Marker Felt"

let SECTION_TITLE_ALBUMS = "Albums"
let SECTION_TITLE_ARTISTS = "Artist"
let SECTION_TITLE_SONGS = "Songs"
