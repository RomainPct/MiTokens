//
//  ViewController.swift
//  MiTokens
//
//  Created by Romain Penchenat on 05/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UISearchBarDelegate {

//    Var
    var _searchTherm:String? = nil
    var _needReload:Bool = false
    var _AirdropsList: [Airdrop] {
        let reload = _needReload
        _needReload = false
        return Singletons.AirdropsDB.getList(wWaiting: ui_waitingRadio.isSelected, wReceived: ui_receivedRadio.isSelected, wSold: ui_soldRadio.isSelected, wSearchTherm: _searchTherm,needReload: reload)
    }
    var airdropSelected:Int?
    
    var targetAirdropRedirection:Airdrop?
    
//    Filters
    
    @IBOutlet weak var ui_searchInput: MiTokens_searchBar!
    @IBOutlet weak var ui_waitingRadio: KGRadioButton!
    @IBOutlet weak var ui_receivedRadio: KGRadioButton!
    @IBOutlet weak var ui_soldRadio: KGRadioButton!
    
    
//    Collection
    @IBOutlet weak var ui_collectionView: UICollectionView!
    @IBOutlet weak var ui_collectionViewFlow: UICollectionViewFlowLayout!
    
    lazy var cellSize:CGSize = CGSize(width: (UIScreen.main.bounds.width/2) - 10, height: 100)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Collection view
        ui_collectionView.dataSource = self
        ui_collectionView.delegate = self
        ui_collectionViewFlow.itemSize = cellSize
        // Navigation
        navigationController?.navigationBar.isTranslucent = false
        // Filters
        ui_searchInput.delegate = self
        [ui_waitingRadio,ui_receivedRadio,ui_soldRadio].forEach { (button) in
            button?.isSelected = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _AirdropsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ui_collectionView.dequeueReusableCell(withReuseIdentifier: "AirdropCell", for: indexPath) as! Airdrop_CollectionViewCell
        cell.bounds.size = cellSize
        let airdrop = _AirdropsList[indexPath.row]
        cell.ui_nameLabel.text = airdrop.name
        airdrop.getValue { (data) in
            if data != nil,
                let price = data!["price"].double {
                let totalValue = price * (airdrop.totalAmount.amountToDouble() ?? 0)
                cell.ui_priceLabel.text = "Valeur : \(totalValue.asAmount(withMaxDigits: 2)) €"
            } else {
                cell.ui_priceLabel.text = ""
            }
        }
        cell.ui_tokensLabel.text = "\(airdrop.totalAmount) \(airdrop.symbol!)"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? Airdrop_CollectionViewCell {
            switch _AirdropsList[indexPath.row].stateEnum {
            case .waiting:
                cell.ui_colorIndicator.backgroundColor = UIColor(named: "Orange")
            case .received:
                cell.ui_colorIndicator.backgroundColor = UIColor(named: "Green")
            case .sold:
                cell.ui_colorIndicator.backgroundColor = UIColor(named: "Blue")
            }
        }
    }
    
//    Collection view delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        airdropSelected = indexPath.row
        performSegue(withIdentifier: "showFocusedAirdrop", sender: nil)
    }
    
//    Searchbar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        _searchTherm = searchText == "" ? nil : searchText
        ui_collectionView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetSearchBar()
        ui_collectionView.reloadData()
    }
    func resetSearchBar() {
        _searchTherm = nil
        ui_searchInput.text = ""
        ui_searchInput.resignFirstResponder()
    }
    @IBAction func leftSearchBar(_ sender: Any) {
        if ui_searchInput.isFirstResponder {
            ui_searchInput.resignFirstResponder()
        }
    }
    
//    Radio buttons
    @IBAction func radioWaiting(_ sender: Any) {
        updateRadio(radioButton: ui_waitingRadio)
    }
    @IBAction func radioReceived(_ sender: Any) {
        updateRadio(radioButton: ui_receivedRadio)
    }
    @IBAction func radioSold(_ sender: Any) {
        updateRadio(radioButton: ui_soldRadio)
    }
    
    func updateRadio(radioButton:KGRadioButton){
        radioButton.isSelected = !radioButton.isSelected
        ui_collectionView.reloadData()
    }
    
//    Unwind
    @IBAction func unwindToHome(segue:UIStoryboardSegue) {
        if let segue = segue as? UIStoryboardSegueWithCompletion {
            segue.completion = {
                if segue.identifier == "goBackHome" {
                    self.performSegue(withIdentifier: "showFocusedAirdrop", sender: nil)
                } else {
                    self.performSegue(withIdentifier: "goToWallets", sender: nil)
                }
            }
        }
    }
    @IBAction func unwindToHomeAndReload(segue:UIStoryboardSegue){
        _needReload = true
        ui_collectionView.reloadData()
    }
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFocusedAirdrop" {
            let nextVC = segue.destination as! Airdrop_ViewController
            if let target = targetAirdropRedirection {
                targetAirdropRedirection = nil
                nextVC.airdrop = target
            } else {
                nextVC.airdrop = _AirdropsList[airdropSelected!]
            }
        }
     }
    
}

