//
//  CalendarVC.swift
//  Guidr
//
//  Created by Flatiron School on 8/18/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import UIKit

enum CalendarMode {
    case AddEvent
    case AddDeleteEvent
    case DeleteEvent
}

class CalendarVC: UIViewController {
    
    var customSC: UISegmentedControl!
    var tableView: UITableView!
    var conflictEvents = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 134/255, green: 36/255, blue: 27/255, alpha: 1)
        title = "Calendar"
        
        setupSC()
        addSCContstraints()
        setupTableView()
        addTableViewConstraints()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testing(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            view.backgroundColor = UIColor.blueColor()
        case 1:
            view.backgroundColor = UIColor.redColor()
        case 2:
            view.backgroundColor = UIColor.yellowColor()
        default: break
        
        }
    }
    
    func setupSC() {
        let items = ["Going", "Not Going", "Conflicts"]
        customSC = UISegmentedControl(items: items)
        customSC.selectedSegmentIndex = 0
        customSC.frame = CGRectZero
        customSC.tintColor = UIColor.whiteColor()
        customSC.addTarget(self, action: #selector(CalendarVC.testing(_:)), forControlEvents: .ValueChanged)
        
        view.addSubview(customSC)
    }
    
    func setupTableView() {
//        tableView = UITableView(frame: CGRectZero)
////        tableView.delegate =
//        view.addSubview(tableView)
    }
    
    func addSCContstraints() {
        customSC.translatesAutoresizingMaskIntoConstraints = false
        customSC.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        customSC.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 5).active = true
        customSC.heightAnchor.constraintEqualToConstant(50).active = true
        customSC.widthAnchor.constraintEqualToConstant(view.frame.width - 50).active = true
    }
    
    func addTableViewConstraints() {
        //let's make magic happen
    }

    // MARK: - Table View methods 
   
    //set the tableview's mode for Going, Not Going, Conflict
    func setMode(calendarMode: CalendarMode) {
        
    }
    
    


}
