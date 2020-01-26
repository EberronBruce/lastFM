//
//  ImageOperations.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/22/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit

//This is the selection fo states when downloaded
enum ImageRecordState {
    case New, Downloaded, Failed
}

//This class is a container class that holds information used in the populating the table view as well as other information
class ImageRecord {
    let name:String
    let url: URL
    var state = ImageRecordState.New
    var image = UIImage(named: IMAGE_LOGO)
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

//This sets up the NSOperations and holds the queues for downloads
class PendingOperations {
    lazy var downloadsInProgress = [IndexPath:Operation]()
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = DOWNLOAD_QUEUE
        return queue
    }()
}

//This class is uses NSOperation to download the image given a url. It constantly checks to see if has been canceled.
class ImageDownloader: Operation {
    
    let imageRecord: ImageRecord
    
    init(imageRecord: ImageRecord) {
        self.imageRecord = imageRecord
    }
    
    override func main() {
                
        do {
            let imageData = try Data(contentsOf: self.imageRecord.url)
            
            if self.isCancelled{
                return
            }
            
            if imageData.count > 0 {
                self.imageRecord.image = UIImage(data: imageData)
                self.imageRecord.state = .Downloaded
            } else {
                self.imageRecord.state = .Failed
                self.imageRecord.image = UIImage(named: IMAGE_LOGO)
            }
        } catch {
            print(IMAGE_OPERATION_DOWNLOAD_ERROR)
        }
        
    }
    
}
