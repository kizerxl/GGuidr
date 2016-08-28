//
//  SettingsTableVC.swift
//  
//
//  Created by Flatiron School on 8/17/16.
//
//

import UIKit
import MessageUI

class SettingsTableVC: UITableViewController, MFMailComposeViewControllerDelegate {
    let headers = ["About","Feedback"]
    let sectonOneRowTitles = ["Guidr - Version 1", "Credits", "Terms Of Use", "About Gary's Guide", "Replay Tutorial"]
    let sectonTwoRowTitles = ["Drop us a line!"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //235 212 203
        self.view.backgroundColor = UIColor(red: 235/255, green: 212/255, blue: 203/255, alpha: 1)
        title = "Settings"
        self.tableView.registerNib(UINib(nibName: "SettingsCell", bundle: nil), forCellReuseIdentifier: "settingsCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Header logic

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        headerView.backgroundColor = UIColor(red: 218/255, green: 159/255, blue: 147/255, alpha: 1)
        
        let headerLabel = UILabel(frame: CGRectMake(5, 5, headerView.frame.size.width - 20, 20))
        headerLabel.font = UIFont(name: "Avenir Medium", size: 16)
        headerLabel.text = headers[section]
        headerView.addSubview(headerLabel)
        
        return headerView
    }

    // MARK: - Row logic

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 5 : 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var desiredText = ""
        var sharedDisplayTitle = ""
        
        if indexPath.section == 0 {
            switch indexPath.row {
                case 0: return // do nothing..
                case 1:
                    desiredText = creditsText
                    sharedDisplayTitle = "Credits"
                case 2:
                    desiredText = termsOfUse
                    sharedDisplayTitle = "Terms Of Use"
                case 3:
                    desiredText = aboutText
                    sharedDisplayTitle = "About"
                case 4: return // for now do nothing until tut screen is done
                default: return
            }
        } else {
            if indexPath.row == 0 {
                sendEmail()
            }
        }
        
        let sharedDisplayVC = SharedDisplayVC()
        sharedDisplayVC.title = sharedDisplayTitle
        sharedDisplayVC.textView.text = desiredText
        self.navigationController!.pushViewController(sharedDisplayVC, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath) as! SettingsTableViewCell
        
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.button.hidden = true
        }

        switch indexPath.section {
            case 0:
                cell.settingsLabel.text = sectonOneRowTitles[indexPath.row]
            break
            
            case 1:
                cell.settingsLabel.text = sectonTwoRowTitles[indexPath.row]
            default:
                //do nothing...
            break
        }

        return cell
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["ello@garysguide.com"])
            mail.setMessageBody("<p>Hey Gary!</p>", isHTML: true)
            presentViewController(mail, animated: true, completion: nil)
        } else {
            print("email not working man...")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
