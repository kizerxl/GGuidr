//
//  CalendarVC.swift
//  Guidr
//
//  Created by Flatiron School on 8/18/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import UIKit
import EventKit

enum CalendarMode {
    case Going
    case NotGoing
    case Conflicts
}

class CalendarVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var customSC: UISegmentedControl!
    var tableView: UITableView!
    var dataSource: [EKEvent]!
    var mode = CalendarMode.Going
    let calEventDataStore = CalendarEventDataStore.sharedInstance
    var reuseIdentifier: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 134/255, green: 36/255, blue: 27/255, alpha: 1)
        title = "Calendar"
        dataSource = calEventDataStore.isGoingEvents
        setupSC()
        addSCContstraints()
        setupTableView()
        addTableViewConstraints()
        
        reuseIdentifier = "calendarCell"
        self.tableView.registerNib(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(false)
//        tableView.reloadData()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCalendarMode(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            dataSource = calEventDataStore.isGoingEvents
            reuseIdentifier = "calendarCell"
        case 1:
            dataSource = calEventDataStore.notGoingEvents
            reuseIdentifier = "calendarCell"
        case 2:
            dataSource = calEventDataStore.conflictEvents
            reuseIdentifier = "calendarCell" //change this in a bit
        default: break
        }
        tableView.reloadData()
    }
    
    func setupSC() {
        let items = ["Going", "Not Going", "Conflicts"]
        customSC = UISegmentedControl(items: items)
        customSC.selectedSegmentIndex = 0
        customSC.frame = CGRectZero
        customSC.tintColor = UIColor.whiteColor()
        customSC.addTarget(self, action: #selector(CalendarVC.setCalendarMode(_:)), forControlEvents: .ValueChanged)
        view.addSubview(customSC)
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRectZero)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    func addSCContstraints() {
        customSC.translatesAutoresizingMaskIntoConstraints = false
        customSC.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 5).active = true
        customSC.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 5).active = true
        customSC.heightAnchor.constraintEqualToConstant(50).active = true
        customSC.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -5).active = true
    }
    
    func addTableViewConstraints() {
        //set the tableview's constraints 
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraintEqualToAnchor(customSC.bottomAnchor, constant: 5).active = true
        tableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -3).active = true
        tableView.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 5).active = true
        tableView.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -5).active = true
    }

    // MARK: - Table View methods 
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("Section called......")
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("THIS METHOD IS BEING CALLED!!!!!")
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CalendarTableViewCell
        print("WE are in cell number \(indexPath.row)")
        
        let currentEvent = dataSource[indexPath.row]
        cell.eventLabel.text = currentEvent.eventIdentifier
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        print("Cell size is called!!!!!!!!!!!")
        return 75
    }
}
