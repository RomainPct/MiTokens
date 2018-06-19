//
//  UIStoryboardSegueWithCompletion.swift
//  MiTokens
//
//  Created by Romain Penchenat on 26/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class UIStoryboardSegueWithCompletion: UIStoryboardSegue {

    var completion: (() -> Void)?
    
    override func perform() {
        super.perform()
        if let completion = completion {
            completion()
        }
    }
    
}
