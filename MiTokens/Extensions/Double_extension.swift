//
//  Double_extension.swift
//  MiTokens
//
//  Created by Romain Penchenat on 23/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import Foundation

extension Double {
    
    func asAmount(withMaxDigits maxDigits:Int) -> String {
        let format = NumberFormatter()
        format.numberStyle = .decimal
        format.groupingSeparator = " "
        format.minimumFractionDigits = 0
        format.maximumFractionDigits = maxDigits
        return format.string(from: NSNumber(value: self))!
    }
    func asAmount(withDigits digits:Int) -> String {
        let format = NumberFormatter()
        format.numberStyle = .decimal
        format.groupingSeparator = " "
        format.minimumFractionDigits = digits
        format.maximumFractionDigits = digits
        return format.string(from: NSNumber(value: self))!
    }
    
}
