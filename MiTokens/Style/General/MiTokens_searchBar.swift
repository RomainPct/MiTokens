//
//  MiTokens_searchBar.swift
//  MiTokens
//
//  Created by Romain Penchenat on 05/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class MiTokens_searchBar: UISearchBar {

    func getSearchFieldSubview() -> UITextField? {
        var subviewToReturn:UITextField?
        let searchBarView = subviews[0]
        for subview in searchBarView.subviews {
            if subview.isKind(of: UITextField.self) {
                subviewToReturn = subview as? UITextField
            }
        }
        return subviewToReturn
    }
    
    override func draw(_ rect: CGRect) {
        // Find the index of the search field in the search bar subviews.
        if let searchField = getSearchFieldSubview() {
            // Set its frame.
            searchField.frame = CGRect(x: 5, y: 5, width: frame.size.width - 10, height: frame.size.height - 10)
            // Border
            searchField.layer.borderWidth = 1
            searchField.layer.borderColor = UIColor(named: "Blue")?.cgColor
            searchField.layer.cornerRadius = 5
            // Set the font and text color of the search field.
            searchField.font = UIFont(name: "Raleway-Regular", size: 13)
            searchField.textColor = UIColor.black
            
            // Set the background color of the search field.
            searchField.layer.backgroundColor = UIColor(named: "Grey")?.cgColor
        }
        super.draw(rect)
    }

}
