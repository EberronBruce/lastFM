//
//  DisclaimerViewController.swift
//  lastFM
//
//  Created by Bruce Burgess on 2/10/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit

class DisclaimerViewController: UIViewController {
    @IBOutlet weak var lastFMButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpView()
    }
    
    func setUpView() {
           
           self.navigationController?.navigationBar.tintColor = COLOR_THEME_RED
           self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
           self.navigationController?.navigationBar.barStyle = .black

       }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func lastFMTapped(_ sender: UIButton) {
        if let url = URL(string: LASTFM_URL) {
            UIApplication.shared.open(url)
        }
    }
   

}
