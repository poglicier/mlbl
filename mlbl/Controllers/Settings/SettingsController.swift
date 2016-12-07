//
//  SettingsController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 28.11.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SettingsController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Пустая реализация нужна для того, чтобы затереть реализацию BaseController,
        // в которой прячется navigationBar
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let aboutController = segue.destination as? AboutController {
            if segue.identifier == "goToAboutLeague" {
                aboutController.imageURL = URL(string: "http://ilovebasket.ru/wp-content/themes/basliga/public/common/logo.png")
                aboutController.text = NSLocalizedString("About league text", comment: "")
            } else if segue.identifier == "goToAboutApp" {
                aboutController.image = UIImage(named: "AppIcon60x60")
                aboutController.text = NSLocalizedString("About app text", comment: "")
            }
        }
    }
    
    // MARK: - Private
    
    fileprivate enum Sections: Int {
        case aboutLeague
        case aboutApp
        case sendError
        case rate
        case changeCompetition
        case count
    }
    
    @IBOutlet fileprivate var appInfoLabel: UILabel!
    @IBOutlet fileprivate var tableView: UITableView!
    fileprivate var aboutLeagueDroppedDown = false

    fileprivate func setupViews() {
        self.title = NSLocalizedString("Settings", comment: "")
        self.appInfoLabel.text = String(format: NSLocalizedString("About info format", comment: ""), Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
        
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    fileprivate func goToAppStore() {
        UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1088559757")!)
    }
        
    fileprivate func goToAboutApp() {
        self.performSegue(withIdentifier: "goToAboutApp", sender: nil)
    }
    
    fileprivate func goToEmailSupport() {
        if MFMailComposeViewController.canSendMail() {
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().tintColor = UIColor.white
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            UINavigationBar.appearance().setBackgroundImage(UIImage.imageForNavigationBar(portrait: true), for: .default)
            
            let composeViewController = MFMailComposeViewController()
            composeViewController.mailComposeDelegate = self
            composeViewController.setToRecipients(["info@ilovebasket.ru"])
            composeViewController.setSubject((Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String) ?? "")
            self.present(composeViewController, animated:true, completion:nil)
        }
    }
}

extension SettingsController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var res: CGFloat = 20
        if let sect = Sections(rawValue: section) {
            switch sect {
            case .aboutLeague:
                res = 0.1
            case .changeCompetition:
                res = 88
            default:
                break
            }
        }
        return res
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let res = UIView()
        res.backgroundColor = UIColor(red: 212/255.0, green: 212/255.0, blue: 212/255.0, alpha: 1)
        return res
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let res = " "
        if let sect = Sections(rawValue: section) {
            switch sect {
            default:
                break
            }
        }
        return res
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var res: CGFloat = 44
        if let sect = Sections(rawValue: indexPath.section) {
            switch sect {
            case .aboutLeague:
                res = self.aboutLeagueDroppedDown ? 44*3 : 44;
            default:
                break
            }
        }
        return res
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let settingsCell = cell as! SettingsCell
        if let sect = Sections(rawValue: indexPath.section) {
            switch sect {
            case .aboutLeague:
                settingsCell.cellType = .simple
                settingsCell.title = NSLocalizedString("About league", comment: "")
                settingsCell.descriptionText = NSLocalizedString("About league text", comment: "")
            case .aboutApp:
                settingsCell.cellType = .disclosure
                settingsCell.title = NSLocalizedString("About app", comment: "")
            case .sendError:
                settingsCell.cellType = .simple
                settingsCell.title = NSLocalizedString("Send error report", comment: "")
            case .rate:
                settingsCell.cellType = .simple
                settingsCell.title = NSLocalizedString("Rate in AppStore", comment: "")
            case .changeCompetition:
                settingsCell.cellType = .red
                settingsCell.title = NSLocalizedString("Change competition", comment: "")
            default:
                settingsCell.cellType = .simple
                settingsCell.title = nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let sect = Sections(rawValue: indexPath.section) {
            switch sect {
            case .aboutLeague:
                self.aboutLeagueDroppedDown = !self.aboutLeagueDroppedDown
                tableView.reloadRows(at: [indexPath], with: .automatic)
            case .aboutApp:
                self.goToAboutApp()
            case .sendError:
                self.goToEmailSupport()
            case .rate:
                self.goToAppStore()
            case .changeCompetition:
                if let chooseCompetitionController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ChooseCompetitionController") as? BaseController {
                    let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
                    fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
                    do {
                        let comp = try self.dataController.mainContext.fetch(fetchRequest).first
                        comp?.isChoosen = false
                        self.dataController.saveContext(self.dataController.mainContext)
                    } catch {}
                    
                    chooseCompetitionController.dataController = self.dataController
                    self.navigationController?.setViewControllers([chooseCompetitionController], animated: false)
                }
            default:
                break
            }
        }
    }
}

extension SettingsController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MFMailComposeViewController {
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.navigationBar.setBackgroundImage(UIImage.imageForNavigationBar(portrait: true), for: .default)
    }
}
