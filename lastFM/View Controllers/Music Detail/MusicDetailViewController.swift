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
    private let reuseIdentifier = MUSIC_IMAGE_CELL
    private var photosUrlArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpView()
    }
    
    func setUpView() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Testing"
        //self.automaticallyAdjustsScrollViewInsets = false
        photosUrlArray = [ "logo", "weezer", "cher", "fallout"]
        imageCollectionView?.delegate = self
        imageCollectionView?.dataSource = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MusicDetailViewController: UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosUrlArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MusicImageCell
        let photoName = photosUrlArray[indexPath.row]
        cell.configureCell(imageName: photoName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.imageCollectionView.frame.size.width, height: self.imageCollectionView.frame.size.height)
    }
    
   
    
}


