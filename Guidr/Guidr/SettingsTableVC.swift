//
//  SettingsTableVC.swift
//  
//
//  Created by Flatiron School on 8/17/16.
//
//

import UIKit

class SettingsTableVC: UITableViewController {
    let headers = ["About","Feedback"]
    let sectonOneRowTitles = ["Guidr - Version 1", "Acknowledgements", "Credits", "Terms Of Use", "About Gary's Guide", "Replay Tutorial"]
    let sectonTwoRowTitles = ["Drop us a line!"]
    
    //Texts for SharedDisplayVC
    let aboutText = "GarysGuide is a global resource and community of professionals that are interested in startups,\n entrepreneurship, social media and technology. It is one of the best resources for discovering technology and\n startup related events, classes, workshops and jobs in New York City, San Francisco / Silicon Valley, London,\n Boston, Los Angeles, Austin and other cities.\n\nWe reach a highly targeted mix of influencers and connectors\n including Startup Founders, CEOs, Entrepreneurs, Technology & Media Executives, Venture Capitalists, Angel\n Investors, Private Equity, Marketers, Product Managers, Analysts, Technologists, Designers, Developers, Government\n Officials, Universities, PR, Press, Media, Bloggers and more.\n\nWe have been written up in the NY Times, Forbes,\n TechCrunch, Mashable, LifeHacker, Gawker, Business Insider, NY Observer / BetaBeat, VentureBeat, Entrepreneur\n Magazine, The Examiner, AM NY, The Next Web, Paid Content and more.\n\nOur current and past sponsors have included\n Google, Microsoft, IBM, HP, Verizon, SAP, MasterCard, The Economist, Stanford University, Columbia University,\n Cornell University, CBS Interactive, Uber, Lyft, WeWork, General Assembly, GrubHub, Casper and many many more.\nHave a question? Report a bug? Feature suggestions? Interested in advertising / sponsorship opportunities? Email us at\n hello@garysguide.com\n"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //235 212 203
        self.view.backgroundColor = UIColor(red: 235/255, green: 212/255, blue: 203/255, alpha: 1)
        title = "Settings"
        self.tableView.registerNib(UINib(nibName: "SettingsCell", bundle: nil), forCellReuseIdentifier: "settingsCell")
    
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

    //will put this in once other screens are done (ie tutorial, etc)
//    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//    
//        
//    
//    }
    
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


}
