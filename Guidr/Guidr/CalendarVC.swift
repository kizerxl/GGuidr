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
    let defaultCalendar = NSCalendar.currentCalendar()
    var reuseIdentifier = "calendarCell"
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 134/255, green: 36/255, blue: 27/255, alpha: 1)
        title = "Calendar"
        calEventDataStore.fetchEventsFromCalendar()
        dataSource = calEventDataStore.isGoingEvents
        setupSC()
        addSCContstraints()
        setupTableView()
        addTableViewConstraints()
        
        self.tableView.registerNib(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCalendarMode(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            calEventDataStore.fetchEventsFromCalendar()
            dataSource = calEventDataStore.isGoingEvents
            mode = .Going
        case 1:
            dataSource = calEventDataStore.notGoingEvents
            mode = .NotGoing
        case 2:
            calEventDataStore.checkForConflicts()
            dataSource = calEventDataStore.conflictEvents
            mode = .Conflicts
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
        tableView.backgroundColor = UIColor(red: 134/255, green: 36/255, blue: 27/255, alpha: 1)
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CalendarTableViewCell
        
        let currentEvent = dataSource[indexPath.row]
        cell.eventLabel.text = currentEvent.title
        cell.dateLabel.text = dateFormatter.stringFromDate(currentEvent.occurrenceDate)

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let goingAction = UITableViewRowAction(style: .Normal, title: "Going") { action, void in
            
            do {
                try self.calEventDataStore.eventStore.saveEvent(self.dataSource[indexPath.row], span: .ThisEvent)
            } catch  {
                print("Did not save Event....")
            }
            self.dataSource.removeAtIndex(indexPath.row)
            self.calEventDataStore.notGoingEvents.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

        }
        
        let notGoingAction = UITableViewRowAction(style: .Normal, title: "Not Going") { action, index in
            do {
                try self.calEventDataStore.eventStore.removeEvent(self.dataSource[indexPath.row], span: .ThisEvent)
            } catch  {
                print("Did not remove Event....")
            }
            self.dataSource.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

        }
    
        let deleteAction = UITableViewRowAction(style: .Destructive, title: "Delete") { action, void in
            do {
                try self.calEventDataStore.eventStore.removeEvent(self.dataSource[indexPath.row], span: .ThisEvent)
            } catch  {
                print("Did not remove Event....")
            }
            
            if self.mode == .NotGoing{
                self.calEventDataStore.notGoingEvents.removeAtIndex(indexPath.row)
            }
            self.dataSource.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        }
        
        
        goingAction.backgroundColor = UIColor.greenColor()
        notGoingAction.backgroundColor = UIColor.orangeColor()
        deleteAction.backgroundColor = UIColor.redColor()
        
        return (mode == .Going || mode == .Conflicts) ? [notGoingAction, deleteAction] : [goingAction, deleteAction]

    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
}
