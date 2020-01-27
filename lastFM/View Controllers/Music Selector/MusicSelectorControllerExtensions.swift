//
//  MusicSelectorControllerExtensions.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/24/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit

//MARK: - TableView Delegates and Datasource Methods
extension MusicSelectorController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        if distanceFromBottom < height {
            if !isFetchingNewPage, let category = getKeyFromTabBar() {
                beginNewPageFetch(category: category)
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return NUMBER_SECTIONS
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CELL_MUSIC, for: indexPath) as? MusicCell {
                let (title, subTitle) = getCellInformation(indexPath: indexPath)
                cell.configureCell(title: title, subTitle: subTitle)
                
                guard let imageRecord = imageRecords[indexPath.row] else {
                    if let defaultImage = UIImage(named: IMAGE_LOGO) {
                        cell.updateCellImage(image: defaultImage)
                    }
                    return cell
                }
                
                if let image = imageRecord.image {
                    cell.updateCellImage(image: image)
                } else {
                    if let defaultImage = UIImage(named: IMAGE_LOGO) {
                        cell.updateCellImage(image: defaultImage)
                    }
                }
                getImageFrom(imageRecord: imageRecord, indexPath: indexPath)
                
                return cell
            } else {
                return MusicCell()
            }
            
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOADING, for: indexPath) as? LoadingCell {
                cell.spinner?.startAnimating()
                return cell
            } else {
                return MusicCell()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return infoContainer.count
        } else if section == 1 && isFetchingNewPage {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let imageURL = infoContainer[indexPath.row].imageUrls?[KEY_EXTRA_LARGE] {
            let dataService = DataService()
            dataService.makeImageCallFrom(url: imageURL) { imageFromCall, error in
                self.processTableViewSection(indexPath: indexPath, image: imageFromCall, error: error)
            }
        }
        
    }
}


//MARK: - Methods Used In TableView Delegates and Datasources
extension MusicSelectorController {
    
    private func processTableViewSection(indexPath: IndexPath, image imageFromCall : UIImage?, error: Error?) {
        DispatchQueue.main.async {
            var params = [String: Any]()
            if let image = imageFromCall {
                params[KEY_IMAGE] = image
            }
            if error != nil {
                if let image = UIImage(named: IMAGE_LOGO) {
                    params[KEY_IMAGE] = image
                }
            }
            params[KEY_DATA] = self.infoContainer[indexPath.row]
            self.performSegue(withIdentifier: SEGUE_DETAIL_VIEW, sender: params)
        }
    }
    
    internal func scrollTableViewToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
    }
    
    internal func getKeyFromTabBar() -> MusicCategory? {
        if let sectionSelected = MusicCategory(rawValue: tabBar.selectedItem!.tag) {
            switch sectionSelected {
            case .albums:
              return .albums
            case .tracks:
                return .tracks
            case .artist:
                return .artist
            }
        }
        return nil
    }
    
    private func beginNewPageFetch(category: MusicCategory) {
        isFetchingNewPage = true
        var pageNumber = self.pageNumberDictionary[category] ?? 1
        pageNumber += 1
        self.pageNumberDictionary[category] = pageNumber
        tableView.reloadSections(IndexSet(integer: FETCH_SECTION), with: .none)
        if let searchText = afterSearch{
            self.makeAPICallForMusicInfoFrom(text: searchText, pageNumber: pageNumber, musicCategory: category)
        }
    }
    
    private func startOperationForImageRecord(imageRecord : ImageRecord, indexPath : IndexPath) {
        switch imageRecord.state {
        case .New:
            startDownload(imageRecord: imageRecord, indexPath: indexPath)
        case .Downloaded:
            break
        case .Failed:
            break
        }
    }
    
    private func startDownload(imageRecord : ImageRecord, indexPath: IndexPath) {
        if pendingOperations.downloadsInProgress[indexPath] != nil {
            return
        }
        
        let downloader = ImageDownloader(imageRecord: imageRecord)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func getImageFrom(imageRecord : ImageRecord?, indexPath : IndexPath) {
        if let state = imageRecord?.state, let record = imageRecord {
            switch state {
            case .Failed: break
            case .New, .Downloaded:
                self.startOperationForImageRecord(imageRecord: record, indexPath: indexPath)
            }
        }
    }
    
    func getCellInformation(indexPath: IndexPath) -> (title : String, subTitle : String) {
        var title : String = STRING_EMPTY
        var subTitle : String = STRING_EMPTY
        let musicInfo = infoContainer[indexPath.row]
        switch musicInfo.category {
        case .albums:
            title = musicInfo.album
            subTitle = musicInfo.artist
        case .tracks:
            title = musicInfo.song
            subTitle = musicInfo.artist
        case .artist:
            title = musicInfo.artist
        }
        
        return (title, subTitle)
    }
    
}

