//
//  ColorIndicator_view.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class ColorIndicator_view: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        layer.maskedCorners = [CACornerMask.layerMinXMaxYCorner,CACornerMask.layerMinXMinYCorner]
    }

}
