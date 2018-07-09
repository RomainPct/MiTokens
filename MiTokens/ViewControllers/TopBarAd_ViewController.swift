//
//  TopBarAd_ViewController.swift
//  MiTokens
//
//  Created by Romain Penchenat on 07/07/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit
import GoogleMobileAds

class TopBarAd_ViewController: UIViewController, GADBannerViewDelegate {

    lazy var ads = AdManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTopBannerAd(ads.bannerView)
        ads.bannerView.delegate = self
    }
    
//    Ad delegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        displayAdView(bannerView)
    }

}
