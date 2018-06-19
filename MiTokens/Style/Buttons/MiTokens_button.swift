//
//  MiTokens_button.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class MiTokens_button: UIButton {
    
    var info:Int?
    
    var isAvalaible: Bool? {
        didSet {
            backgroundColor = isAvalaible! ? UIColor(named: "Green") : UIColor(named: "Grey")
            tintColor = isAvalaible! ? UIColor.white : UIColor.black.withAlphaComponent(0.3)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        backgroundColor = UIColor(named: "Green")
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 13, bottom: 8, right: 13)
        
        titleLabel?.font = UIFont(name: "Raleway-Bold", size: 13)
        if isAvalaible == nil {
            isAvalaible = true
        }
    }

}
