//
//  ScrollView.swift
//  MiTokens
//
//  Created by Romain Penchenat on 11/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview.frame.contains(point) {
                return true
            }
        }
        return false
    }
    
}
