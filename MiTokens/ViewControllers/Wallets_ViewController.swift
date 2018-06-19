//
//  Wallets_ViewController.swift
//  MiTokens
//
//  Created by Romain Penchenat on 21/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class Wallets_ViewController: UIViewController, UICollectionViewDataSource, UITableViewDataSource {
    
    @IBOutlet weak var ui_noWalletInformationsView: UIView!
    @IBOutlet weak var ui_walletsView: UIView!
    
    @IBOutlet weak var ui_walletsNameCollectionView: UICollectionView!
    @IBOutlet weak var ui_tokensTableView: UITableView!
    @IBOutlet weak var ui_numberOfTokensLabel: Body_label!
    
    
    var homeWillNeedReload:Bool = false
    private var lastSelectedToken:token?
    private var _focusedWallet:Wallet?
    private var _focusedWalletIndex:Int?
    var focusedWalletIndex: Int {
        get {
            return _focusedWalletIndex ?? 0
        }
        set {
            _focusedWalletIndex = newValue
            _focusedWallet = Singletons.WalletsDB.wallets_list[newValue]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ui_walletsNameCollectionView.dataSource = self
        ui_tokensTableView.rowHeight = 60
        ui_tokensTableView.estimatedRowHeight = 60
        ui_tokensTableView.dataSource = self
        loadTokens()
        showTheGoodPart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    Collection View Data Source : Wallet Names
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Singletons.WalletsDB.wallets_list.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ui_walletsNameCollectionView.dequeueReusableCell(withReuseIdentifier: "walletNameCell", for: indexPath) as! WalletName_CollectionViewCell
        cell.ui_nameButton.info = indexPath.row
        if indexPath.row >= Singletons.WalletsDB.wallets_list.count {
            // Bouton spécial ajout de wallet
            cell.ui_nameButton.isAvalaible = false
            cell.ui_nameButton.setTitle("Nouveau wallet", for: .normal)
        } else {
            // Bouton classique de wallet
            cell.ui_nameButton.setTitle(Singletons.WalletsDB.wallets_list[indexPath.row].name, for: .normal)
            if indexPath.row != focusedWalletIndex {
                cell.ui_nameButton.isAvalaible = false
            } else {
                cell.ui_nameButton.isAvalaible = true
            }
        }
        return cell
    }
    
//    Changer le wallet actuellement focus
    @IBAction func changeFocusedWallet(_ sender: MiTokens_button) {
        if let position = sender.info, position < Singletons.WalletsDB.wallets_list.count {
            // Supprimer le focus sur le bouton actuel
            if let oldFocusedButton = ui_walletsNameCollectionView.cellForItem(at: IndexPath(row: focusedWalletIndex, section: 0))?.subviews.first?.subviews.first as? MiTokens_button {
                oldFocusedButton.isAvalaible = false
            }
            // Lancer le focus sur le nouveau bouton
            sender.isAvalaible = true
            // Charger les tokens sur le wallet
            loadTokens(wFocusedWallet: position)
            ui_tokensTableView.reloadData()
        } else {
            performSegue(withIdentifier: "showAddWalletForm", sender: nil)
        }
    }
    
    
    
    
//    TableView Data Source : Tokens on wallet
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let focusedWallet = _focusedWallet else {
            return 0
        }
        return focusedWallet.tokensList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < _focusedWallet!.tokensList.count {
            let token = _focusedWallet!.tokensList[indexPath.row]
            if token.getLink(inWallet: _focusedWallet!) == nil, token.symbol != "ETH" {
                let cell = ui_tokensTableView.dequeueReusableCell(withIdentifier: "notLinkedToken") as! NotLinkedToken_TableViewCell
                cell.ui_amountLabel.text = "\(token.realBalance) \(token.symbol)"
                token.getValue(ofSmartContract: token.smartContract, wName: token.name, wSymbol: token.symbol) { (value) in
                    if value != nil {
                        let totalValue = value! * token.realBalance.amountToDouble()!
                        cell.ui_priceLabel.text = "[\(totalValue.asAmount(withDigits: 2)) €]"
                    } else {
                        cell.ui_priceLabel.text = ""
                    }
                }
                return cell
            } else {
                let cell = ui_tokensTableView.dequeueReusableCell(withIdentifier: "linkedToken") as! LinkedToken_TableViewCell
                cell.ui_amountLabel.text = "\(token.realBalance) \(token.symbol)"
                if token.symbol == "ETH" {
                    cell.ui_linkLabel.isHidden = true
                } else if let airdrop = Singletons.AirdropsDB.getAirdrop(withId: token.getLink(inWallet: _focusedWallet!)!.airdropId) {
                    cell.ui_linkLabel.text = "associé à \(airdrop.name)"
                }
                token.getValue(ofSmartContract: token.smartContract, wName: token.name, wSymbol: token.symbol) { (value) in
                    if value != nil {
                        let totalValue = value! * token.realBalance.amountToDouble()!
                        cell.ui_priceLabel.text = "[\(totalValue.asAmount(withDigits: 2)) €]"
                    } else {
                        cell.ui_priceLabel.text = ""
                    }
                }
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                cell.addGestureRecognizer(tap)
                return cell
            }
        } else {
            return ui_tokensTableView.dequeueReusableCell(withIdentifier: "deleteWallet")!
        }
    }
    
//    Afficher l'airdrop
    @objc func handleTap(_ sender:UITapGestureRecognizer){
        let position = sender.location(in: ui_tokensTableView)
        if let indexPath = ui_tokensTableView.indexPathForRow(at: position) {
            lastSelectedToken = _focusedWallet!.tokensList[indexPath.row]
            performSegue(withIdentifier: "displayAirdrop", sender: nil)
        }
    }
    
//    Charger le contenu de la page
    private func loadTokens(wFocusedWallet position:Int = 0){
        guard Singletons.WalletsDB.wallets_list.count != 0 else {
            return
        }
        focusedWalletIndex = position
        if let focusedWallet = _focusedWallet {
            if focusedWallet.tokensList.count == 0 {
                focusedWallet.updateBalances {
                    self.ui_numberOfTokensLabel.text = "\(focusedWallet.tokensList.count) tokens"
                    self.ui_tokensTableView.reloadData()
                }
            } else {
                self.ui_numberOfTokensLabel.text = "\(focusedWallet.tokensList.count) tokens"
            }
        }
    }
    private func showTheGoodPart() {
        if Singletons.WalletsDB.wallets_list.count == 0 {
            // Cacher la partie d'affichage des wallets
            ui_walletsView.isHidden = true
        } else {
            // Cacher la partie de présentation
            ui_walletsView.isHidden = false
            ui_noWalletInformationsView.addConstraint(NSLayoutConstraint(item: ui_noWalletInformationsView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0))
        }
    }
    func newWalletAdded(){
        showTheGoodPart()
        loadTokens(wFocusedWallet: Singletons.WalletsDB.wallets_list.count - 1)
        ui_walletsNameCollectionView.reloadData()
        ui_tokensTableView.reloadData()
    }
    @IBAction func wantToCreateLinkWithAirdrop(_ sender: UIButton) {
        let cell = sender.superview!.superview!.superview!
        if let indexPath = ui_tokensTableView.indexPathForRow(at: cell.frame.origin) {
            lastSelectedToken = _focusedWallet!.tokensList[indexPath.row]
            performSegue(withIdentifier: "linkToAirdrop", sender: nil)
        }
    }
    
//    Supprimer le wallet
    @IBAction func deleteCurrentWallet(_ sender: Any) {
        let alertSheet = UIAlertController(title: "Supprimer ce wallet", message: "Souhaitez-vous vraiment supprimer ce wallet de l'application MiTokens ?", preferredStyle: .actionSheet)
        alertSheet.addAction(UIAlertAction(title: "Supprimer ce wallet", style: .destructive, handler: { (_) in
            Singletons.WalletsDB.removeWallet(atIndex: self.focusedWalletIndex)
            self.focusedWalletIndex = 0
            self.ui_walletsNameCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.left, animated: true)
            self.ui_walletsNameCollectionView.reloadData()
            self.ui_tokensTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
            self.ui_tokensTableView.reloadData()
        }))
        alertSheet.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        present(alertSheet, animated: true, completion: nil)
    }
    
    
//    Unwind
    @IBAction func unwindToWallets(segue:UIStoryboardSegue) {}
    
    @IBAction func unwindToWalletsAndReload(segue:UIStoryboardSegue) {
        loadTokens(wFocusedWallet: focusedWalletIndex)
        ui_tokensTableView.reloadData()
    }
    
//    Fermeture du ViewController
    @IBAction func closeWallets(_ sender: Any) {
        if homeWillNeedReload {
            performSegue(withIdentifier: "unwindAndReload", sender: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
//    Gestion segue vers CreateALink
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "linkToAirdrop",
            let nextVC = segue.destination as? CreateALink_ViewController {
            nextVC.token = lastSelectedToken
            nextVC.currentWalletAddress = _focusedWallet!.erc20Address
        } else if segue.identifier == "displayAirdrop",
            let nextVC = segue.destination as? Airdrop_ViewController,
            let airdropID = lastSelectedToken?.getLink(inWallet: _focusedWallet!)?.airdropId {
            nextVC.airdrop = Singletons.AirdropsDB.getAirdrop(withId: airdropID)
            nextVC.comeFromWallets = true
        }
    }

}
