//
//  CalendarEventDataStore.swift
//  Guidr
//
//  Created by Flatiron School on 8/20/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import Foundation
import EventKit

let settingsNotification = "openSettings"

class CalendarEventDataStore {
    var isGoingEvents: [EKEvent] = []
    var notGoingEvents: [EKEvent] = []
    var conflictEvents: [EKEvent] = []
    var eventStore = EKEventStore()
    var calendar: EKCalendar!
    
    private var appName = "Guidr"
    
    static let sharedInstance = CalendarEventDataStore()
    
    private init() {}

    func checkCalendarAuthorizationStatus() {
        print("Start checking for calendar!!!!")
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        print("The status is \(status)")
        print("The status is \(status.rawValue)")
        print("The status is \(status.hashValue)")
        switch (status) {
        case EKAuthorizationStatus.NotDetermined: // This happens on first-run
            print("Auth status not determined!!!")
            requestAccessToCalendar()
        case EKAuthorizationStatus.Authorized:
            print("Let's setup the calendar")
            calendarSetup() //setup the calendar
            break
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
            print("Auth denied")
            //TODO: handle this
            // let's send out a nsnotification to the respective controller that the user has 
            // to manually go into settings and enable the calendar
            //The user has to manually grant access
            //What I could do here is to simply
            //some logic to have user open settings
            //                    let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            //                    UIApplication.sharedApplication().openURL(openSettingsUrl!)
            
            //Do a shared method since this functinality gets used twice
            print("Access to calendar is restricted man!!!!!!!!! <-")
            NSNotificationCenter.defaultCenter().postNotificationName(settingsNotification, object: self)
            break
            
        }
    }
    
    func calendarSetup() {
        
        // If the app's calendar already exists on the phone, use it
        let calendars = eventStore.calendarsForEntityType(.Event)
        for calendar: EKCalendar in calendars {
            if calendar.title == appName {
                print("calendar was found!!!!!")
                self.calendar = calendar
                return
            }
        }
        print("Making the calendar")
        // Otherwise, create one
        calendar = EKCalendar(forEntityType: .Event, eventStore: eventStore)
        calendar.title = appName
        
        calendar.source = eventStore.sources.filter {
            (source: EKSource) -> Bool in
            source.sourceType.rawValue == EKSourceType.Local.rawValue
            }.first!
        
        do {
            try self.eventStore.saveCalendar(calendar, commit: true)
            print("saved the calendar")
            
        } catch {
            print("Calendar could not be saved")
            //WE will use NSNotification to instruct user
            //by opening an Alert on the VC
            NSNotificationCenter.defaultCenter().postNotificationName(settingsNotification, object: nil)
        }
        
        
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
            (accessGranted: Bool, error: NSError?) in
            
            if accessGranted == true {
                dispatch_async(dispatch_get_main_queue(), {
                    self.calendarSetup()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    //WE will use NSNotification to instruct user 
                    //by opening an Alert on the VC
                    //The user has to manually grant access
                    //What I could do here is to simply 
                    //some logic to have user open settings
                    //                    let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                    //                    UIApplication.sharedApplication().openURL(openSettingsUrl!)
                    NSNotificationCenter.defaultCenter().postNotificationName(settingsNotification, object: nil)
                })
            }
        })
    }
    
    func fetchEventsFromCalendar() {
        isGoingEvents = [] //clear the array
        let startDate = NSDate()
        let endDate = NSDate(timeIntervalSinceNow: 60*60*24*30)
        let predicate = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: [calendar])
        let events = eventStore.eventsMatchingPredicate(predicate) as [EKEvent]
        
        for event in events {
            isGoingEvents.append(event)
        }
    }
    
    func checkForConflicts() {
        fetchEventsFromCalendar()
        conflictEvents = [] //reset the conflicts array
        if isGoingEvents.count > 1 {
            var startDate = isGoingEvents[0].startDate
            var nextDate: NSDate!
            var currentEvent: EKEvent!
            
            for i in 1..<isGoingEvents.count {
                currentEvent = isGoingEvents[i]
                nextDate = currentEvent.startDate
                if startDate.isEqualToDate(nextDate) || startDate.compare(nextDate) == .OrderedDescending {
                    conflictEvents.append(currentEvent)
                }
                startDate = currentEvent.startDate
            }
        }
    }
}