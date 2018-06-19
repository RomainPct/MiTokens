//
//  NavBar_button.swift
//  MiTokens
//
//  Created by Romain Penchenat on 21/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class NavBar_button: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        backgroundColor = UIColor(named: "Grey")
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        titleLabel?.font = UIFont(name: "Raleway-Bold", size: 13)
        tintColor = UIColor(named: "Blue")
    }

}
