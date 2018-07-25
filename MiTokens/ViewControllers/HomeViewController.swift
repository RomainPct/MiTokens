//
//  ViewController.swift
//  MiTokens
//
//  Created by Romain Penchenat on 05/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit
//import Crashlytics

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
    
//    Intro
    @IBOutlet weak var ui_introduction: WhiteView!
    lazy var cs_introductionHeight = NSLayoutConstraint(item: ui_introduction, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
    
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
        ui_collectionViewFlow.footerReferenceSize = CGSize(width: 0, height: 56)
        // Navigation
        navigationController?.navigationBar.isTranslucent = false
        // Filters
        ui_searchInput.delegate = self
        [ui_waitingRadio,ui_receivedRadio,ui_soldRadio].forEach { (button) in
            button?.isSelected = true
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ShortcutNewAirdrop, object: nil, queue: nil) { (_) in
            self.performSegue(withIdentifier: "goToNewAirdrop", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !_AirdropsList.isEmpty {
            ui_introduction.addConstraint(cs_introductionHeight)
            ui_introduction.clipsToBounds = true
        } else if cs_introductionHeight.isActive, _AirdropsList.isEmpty {
            cs_introductionHeight.isActive = false
            ui_introduction.clipsToBounds = false
        }
        return _AirdropsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ui_collectionView.dequeueReusableCell(withReuseIdentifier: "AirdropCell", for: indexPath) as! Airdrop_CollectionViewCell
        cell.bounds.size = cellSize
        let airdrop = _AirdropsList[indexPath.row]
        cell.ui_nameLabel.text = airdrop.name
        cell.ui_tokensLabel.text = "\(airdrop.totalAmount) \(airdrop.symbol!)"
        airdrop.getValue { (value) in
            // Vérifier que l'airdrop en question est toujours celui à cette case
            if let cellName = cell.ui_nameLabel.text,
                cellName == airdrop.name {
                if value != nil {
                    let totalValue = value!.getTotalValue(forAmount: (airdrop.totalAmount.amountToDouble() ?? 0))
                    cell.ui_priceLabel.text = "Valeur : \(totalValue.asAmount(withDigits: 2)) €"
                } else {
                    cell.ui_priceLabel.text = ""
                }
            }
        }
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = ui_collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
        return footerView
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
                    if self.targetAirdropRedirection != nil {
                        self.ui_collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: true)
                        self.performSegue(withIdentifier: "showFocusedAirdrop", sender: nil)
                    }
                } else {
                    self.tabBarController?.selectedIndex = 1
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
                // Vérifier avant de lancer le segue si l'airdrop selected n'est pas vide
                nextVC.airdrop = _AirdropsList[airdropSelected!]
                airdropSelected = nil
            }
        }
     }
    
}

