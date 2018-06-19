//
//  MiTokens_UINavigationItem.swift
//  MiTokens
//
//  Created by Romain Penchenat on 05/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class MiTokens_UINavigationItem: UINavigationItem {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIScreen.main
        let titleLabel = Title_label(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 100, height: view.bounds.height))
        titleLabel.text = self.title
        titleLabel.font = UIFont(name: "Raleway-ExtraLight", size: 34)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        self.titleView = titleLabel
    }
    
}
