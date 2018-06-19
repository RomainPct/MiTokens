//
//  AdManager_Model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 09/06/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import GoogleMobileAds

class AdManager {
    
    lazy var bannerView: GADBannerView = {
        var ad = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        // bannerView.adUnitID = "ca-app-pub-6024155085751040/2906991911" // Réel
        ad.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Test
        return ad
    }()
    
}
