//
//  APIManager_Model.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import Alamofire
import SwiftyJSON
import Foundation

class APIManager {
    
    private let _KEY_API_ethphlorer = "lmtk5156APeR61"
    private let _KEY_API_etherscan = "KMQXRHS3F2ZQK9A8MGXEJJZKMNWSP46NUE"
    
    static let _URL_library = try! NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0].asURL()
    
    func getTokensOnAccount(withPublicKey publicKey:String,received:@escaping (JSON?)->Void) {
        let urlString = "https://api.ethplorer.io/getAddressInfo/\(publicKey)?apiKey=\(_KEY_API_ethphlorer)"
        if let url = URL(string: urlString) {
            Alamofire.request(url).responseJSON { (response) in
                if let data = try? JSON(data: response.data!) {
                    if data["error"] == JSON.null {
                        received(data)
                    } else {
                        received(nil)
                    }
                } else {
                    print("ERROR : \(response.error)")
                    received(nil)
                }
            }
        }
    }
    
    func getCoinMarketCapListing(handler:@escaping(JSON) -> Void) {
        let urlString = "https://api.coinmarketcap.com/v2/listings/"
        if let url = URL(string: urlString) {
            Alamofire.request(url).responseJSON { (response) in
                if let data = response.data,
                    let json = try? JSON(data: data) {
                    handler(json)
                }
            }
        }
    }
    
    func getValueOnCMC(forCMCId id:String, handler:@escaping(JSON) -> Void) {
        let urlString = "https://api.coinmarketcap.com/v2/ticker/\(id)/?convert=EUR"
        if let url = URL(string: urlString) {
            Alamofire.request(url).responseJSON { (response) in
                if let data = response.data,
                    let json = try? JSON(data: data) {
                    handler(json)
                }
            }
        }
    }
    
    func getValueOnIdex(forSymbol symbol:String, handler:@escaping(JSON) -> Void){
        let urlString = "https://api.idex.market/returnTicker?market=ETH_\(symbol)"
        if let url = URL(string: urlString) {
            Alamofire.request(url).responseJSON { (response) in
                if let data = response.data,
                    let json = try? JSON(data: data) {
                    handler(json)
                }
            }
        }
    }
    
}
