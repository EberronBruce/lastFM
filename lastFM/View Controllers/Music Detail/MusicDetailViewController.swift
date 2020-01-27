//
//  MusicDetailViewController.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/21/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit

class MusicDetailViewController: UIViewController {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var albumTextLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songTextLabel: UILabel!
    @IBOutlet weak var artistTitleLabel: UILabel!
    @IBOutlet weak var artistButton: UIButton!
    
    var musicInfo : MusicInfo! = nil
    var imageArray : [UIImage]? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpView()
        NotificationCenter.default.addObserver(self, selector: #selector(actOnArtistInformationCompleteNotification(_:)), name: NOTIFY_API_ARTIST, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func setUpView() {
        //self.automaticallyAdjustsScrollViewInsets = false
        imageCollectionView?.delegate = self
        imageCollectionView?.dataSource = self
        
        self.navigationController?.navigationBar.tintColor = COLOR_THEME_RED
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.barStyle = .black
        
        setupLabels()
        
        artistButton.setTitle(musicInfo.artist, for: .normal)
    }
    
    private func setupLabels(){
        switch musicInfo.category {
        case .albums:
            self.title = musicInfo.album
            songTextLabel.isHidden = true
            songTitleLabel.isHidden = true
            albumTextLabel.text = musicInfo.album
        case .tracks:
            self.title = musicInfo.song
            albumTextLabel.isHidden = true
            albumTitleLabel.isHidden = true
            songTextLabel.text = musicInfo.song
        case .artist:
            self.title = musicInfo.artist
            songTextLabel.isHidden = true
            songTitleLabel.isHidden = true
            albumTextLabel.isHidden = true
            albumTitleLabel.isHidden = true
            break
        }
    }
    
    @IBAction func artistButtonTapped(_ sender: UIButton) {
        print("Button tapped")
        let dataService = DataService()
        dataService.getArtistDetailsFromApiCall(musicInfo.artist)
    }
    
    @objc func actOnArtistInformationCompleteNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            if let data = notification.userInfo as? [String : String] {
                if let link = data[KEY_ARTIST] {
                    let webView = WebViewController(string: link)
                    self.present(webView, animated: true)
                } else {
                    print("NOTHING")
                }
            }
        }
    }
    
    private func displayAlertView() {
        let alertController = UIAlertController(title: "NO Artist", message: "Testing", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension MusicDetailViewController: UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imageArray != nil {
            return imageArray!.count
        }
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_MUSIC_IMAGE, for: indexPath) as! MusicImageCell
        if let image = imageArray?[indexPath.row] {
            cell.configureCell(image: image)
        } 
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.imageCollectionView.frame.size.width, height: self.imageCollectionView.frame.size.height)
    }
    
   
    
}


