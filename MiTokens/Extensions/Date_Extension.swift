//
//  Date_Extension.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/06/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import Foundation

extension Date {
    
    func format() -> String {
        let format = DateFormatter()
        format.dateStyle = .medium
        format.timeStyle = .short
        return format.string(from: self)
    }
    
}
