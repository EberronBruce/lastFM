//
//  Constants.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/21/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit

/*
 Used for storing constansts used in the application
 */

let URL_BASE = "http://ws.audioscrobbler.com/2.0/"
let URL_ALBUM = "?method=album.search&album="
let URL_ARTIST = "?method=artist.search&artist="
let URL_TRACK = "?method=track.search&track="
let URL_FORMAT_JSON = "&format=json"
let URL_LIMIT = "&limit="
let URL_PAGE = "&page="
let URL_ARTIST_INFO = "?method=artist.getinfo&artist="
let URL_API_KEY = "&api_key=27939c41a4d5e9db202b2036c5bc12df"
let SECERT_KEY = "d59e4e5f555604aa476e83202bef1ee6"

let NUMBER_LIMIT = 20
let NUMBER_SECTIONS = 2

let CELL_MUSIC = "musicCell"
let CELL_MUSIC_IMAGE = "musicImageCell"
let CELL_LOADING = "loadingCell"
let CELL_STYLE_CORNER_RADIUS : CGFloat = 5

let NOTIFY_API_MUSIC_DICT = Notification.Name("api.notify.music.dictionary.complete")
let NOTIFY_API_MUSIC_ARRAY = Notification.Name("api.notify.music.array.complete")
let NOTIFY_API_IMAGE = Notification.Name("api.notify.image.complete")
let NOTIFY_API_ARTIST = Notification.Name("api.notify.artist.details.complete")

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
let KEY_DATA = "data"
let KEY_BIO = "bio"
let KEY_LINKS = "links"
let KEY_LINK = "link"
let KEY_HREF = "href"

let CODE_HTTP_SPACE = "%20"
let STRING_SPACE = " "
let STRING_EMPTY = ""

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

let KEY_INFO_ARRAY = "infoContainer"
let KEY_INFO_DICTIONARY_CATEGORY = "musicInfoContainer"
let KEY_IMAGE_GET = "musicImageGet"

let FETCH_SECTION = 1

let SEGUE_DETAIL_VIEW = "detailViewSegue"

let WEB_POST = "POST"
let WEB_APPLICATION_JSON =  "application/json"
let WEB_CONTENT_TYPE =  "Content-Type"
let WEB_APPLICATION_JSON_REQUEST = "application/jsonrequest"
let WEB_ACCEPT = "Accept"
let WEB_IDENTITY = "identity"
let WEB_CONTENT_ENCODING = "Content-Encoding"
let WEB_ERROR_PARSING = "Error parsing: "
let WEB_FAILED_TO_PARSE = "Failed to parse: "
let WEB_ERROR_UNKNOWN = "Unknown Error"
let WEB_GET_DATA_FROM = "Get data from: "
let WEB_RETURN_NIL = " return nil"

let ALERT_OK_BUTTON = "OK"
let ALERT_NO_ARTIST_TITLE = "NO ARTIST BIO"
let ALERT_NO_ARTIST_MESSAGE = "The bio information for this artists could not be retrieved."

let LASTFM_URL = "https://www.last.fm"
