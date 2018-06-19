//
//  WhiteView.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class WhiteView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
//        clipsToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.1
    }

}
