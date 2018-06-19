//
//  GreyView.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class GreyView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        backgroundColor = UIColor(named: "Grey")
//        clipsToBounds = true
        
        layer.shadowColor = UIColor(named: "ShadowColor")?.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 1
    }

}
