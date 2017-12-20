//
//  ChooseCompetitionController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 12.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class ChooseCompetitionController: BaseController {
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var emptyLabel: UILabel!
    fileprivate var refreshButton: UIButton?
    
    lazy fileprivate var fetchedResultsController: NSFetchedResultsController<Competition> = {
        let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "compType < 0 AND parent != nil")
        let isLanguageRu = self.dataController.language.contains("ru")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: isLanguageRu ? "parent.compShortNameRu" : "parent.compShortNameEn", ascending: true),
                                        NSSortDescriptor(key: isLanguageRu ? "compAbcNameRu" : "compAbcNameEn", ascending: true), NSSortDescriptor(key: self.dataController.language.contains("ru") ? "compShortNameRu" : "compShortNameEn", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: isLanguageRu ? "parent.compShortNameRu" : "parent.compShortNameEn",
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        
        self.getData(true)
    }
    
    // MARK: - Public
    
    var pushesController: PushesController!
    
    // MARK: - Private
    
    fileprivate func setupTableView() {
        self.tableView.layer.cornerRadius = 10
        self.tableView.layer.masksToBounds = true
    }
    
    fileprivate func getData(_ showIndicator: Bool) {
        if (showIndicator) {
            self.activityView.startAnimating()
            self.tableView.isHidden = true
            self.emptyLabel.isHidden = true
        }
        
        self.dataController.getCompetitions(parentCompId: nil) { [weak self] (error) in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                if let _ = error {
                    strongSelf.emptyLabel.text = error?.localizedDescription
                    strongSelf.tableView.isHidden = true
                    strongSelf.emptyLabel.isHidden = false
                    
                    let refreshButton = UIButton(type: .custom)
                    let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSAttributedStringKey.underlineStyle : 1, NSAttributedStringKey.foregroundColor : UIColor.mlblLightOrangeColor()])
                    refreshButton.setAttributedTitle(attrString, for: UIControlState())
                    refreshButton.addTarget(strongSelf, action: #selector(strongSelf.refreshPlayersDidTap), for: .touchUpInside)
                    strongSelf.view.addSubview(refreshButton)
                    
                    refreshButton.snp.makeConstraints({ (make) in
                        make.centerX.equalTo(0)
                        make.top.equalTo(strongSelf.emptyLabel.snp.bottom)
                    })
                    
                    strongSelf.refreshButton = refreshButton
                } else {
                    strongSelf.emptyLabel.isHidden = true
                    strongSelf.tableView.isHidden = false
                    strongSelf.title = NSLocalizedString("Choose competition", comment: "")
                }
            }
        }
    }
    
    fileprivate func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let comp = fetchedResultsController.object(at: indexPath)
        
        let isLanguageRu = self.dataController.language.contains("ru")
        let shortName = isLanguageRu ? comp.compShortNameRu : comp.compShortNameEn
        
        if let _ = shortName {
            cell.textLabel?.text = shortName!
        } else {
            cell.textLabel?.text = "-"
        }
    }
    
    fileprivate func goToMain() {
        if let selectedPath = self.tableView.indexPathForSelectedRow {
            self.activityView.startAnimating()
            self.tableView.isHidden = true
            self.emptyLabel.isHidden = true
            
            let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
            fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
            
            do {
                let oldComp = try self.dataController.mainContext.fetch(fetchRequest).first
                let newComp = self.fetchedResultsController.object(at: selectedPath)
                if oldComp != newComp {
                    oldComp?.isChoosen = false
                    newComp.isChoosen = true

                    // Удаляем игроков старого чемпионата
                    let playersRequest = NSFetchRequest<Player>(entityName: Player.entityName())
                    do {
                        let players = try self.dataController.mainContext.fetch(playersRequest)
                        for player in players {
                            self.dataController.mainContext.delete(player)
                            print("DELETE Player \(player.lastNameRu ?? "")")
                        }
                    }
                    
                    // Удаляем игры старого чемпионата
                    let gamesRequest = NSFetchRequest<Game>(entityName: Game.entityName())
                    do {
                        let games = try self.dataController.mainContext.fetch(gamesRequest)
                        for game in games {
                            self.dataController.mainContext.delete(game)
                            
                            if let date = game.date {
                                print("DELETE Game \(date)")
                            } else {
                                print("DELETE Game UNKNOWN DATE")
                            }
                        }
                    }
                    
                    self.dataController.saveContext(self.dataController.mainContext)
                    
                    // Запрос поддерева выбранного чемпионата
                    if let compId = newComp.objectId?.intValue {
                        self.dataController.getCompetitions(parentCompId: compId) { [weak self] (error) in
                            if let strongSelf = self {
                                strongSelf.activityView.stopAnimating()
                                if let _ = error {
                                    strongSelf.emptyLabel.text = error?.localizedDescription
                                    strongSelf.tableView.isHidden = true
                                    strongSelf.emptyLabel.isHidden = false
                                    
                                    let refreshButton = UIButton(type: .custom)
                                    let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSAttributedStringKey.underlineStyle : 1, NSAttributedStringKey.foregroundColor : UIColor.mlblLightOrangeColor()])
                                    refreshButton.setAttributedTitle(attrString, for: UIControlState())
                                    refreshButton.addTarget(strongSelf, action: #selector(strongSelf.refreshPlayersDidTap), for: .touchUpInside)
                                    strongSelf.view.addSubview(refreshButton)
                                    
                                    refreshButton.snp.makeConstraints({ (make) in
                                        make.centerX.equalTo(0)
                                        make.top.equalTo(strongSelf.emptyLabel.snp.bottom)
                                    })
                                    
                                    strongSelf.refreshButton = refreshButton
                                } else {
                                    strongSelf.emptyLabel.isHidden = true
                                    strongSelf.tableView.isHidden = false
                                    
                                    strongSelf.performSegue(withIdentifier: "goToMain", sender: nil)
                                }
                            }
                        }
                    }
                }
            } catch {}
        }
    }
    
    @objc fileprivate func refreshPlayersDidTap(_ sender: UIButton) {
        self.refreshButton?.removeFromSuperview()
        self.refreshButton = nil
        self.getData(true)
    }
    
    override func willEnterForegroud() {
        if self.navigationController?.topViewController == self {
            if let _ = self.refreshButton {
                self.refreshButton?.removeFromSuperview()
                self.refreshButton = nil
                self.getData(true)
            } else {
                self.getData(false)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMain" {
            let main = segue.destination as! MainController
            main.dataController = self.dataController
            main.pushesController = self.pushesController
            
        }
    }
    
    @IBAction fileprivate func prepareForUnwind(_ segue: UIStoryboardSegue) {
    }
}

extension ChooseCompetitionController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ frc: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with:.fade)
            
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with:.fade)
            
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
            
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with:.fade)
            self.tableView.insertRows(at: [newIndexPath!], with:.fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch(type) {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with:.fade)
            
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with:.fade)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}

extension ChooseCompetitionController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = self.fetchedResultsController.sections?[section]
        if let competition = sectionInfo?.objects?.first as? Competition {
            let isLanguageRu = self.dataController.language.contains("ru")
            return isLanguageRu ? competition.parent?.compShortNameRu : competition.parent?.compShortNameEn
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }

        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.mlblLightOrangeColor()
        let label = UILabel()
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
        } else {
            label.font = UIFont.systemFont(ofSize: 17)
        }
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor.white
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.right.bottom.equalTo(0)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let cellIdentifier = "chooseCompCell"
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.textColor = UIColor.mlblDarkOrangeColor()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.configureCell(cell, atIndexPath:indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.goToMain()
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Пустая реализация нужна для того, чтобы затереть реализацию BaseController,
        // в которой прячется navigationBar
    }
}
