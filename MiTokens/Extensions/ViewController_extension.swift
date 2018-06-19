//
//  ViewController_extension.swift
//  MiTokens
//
//  Created by Romain Penchenat on 09/06/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension UIViewController {
    
    func loadTopBannerAd(_ bannerView:GADBannerView){
        bannerView.rootViewController = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.alpha = 0
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        bannerView.load(GADRequest())
    }
    
    func displayAdView(_ bannerView:GADBannerView){
        UIView.animate(withDuration: 0.2) {
            bannerView.alpha = 1
        }
    }
    
}
