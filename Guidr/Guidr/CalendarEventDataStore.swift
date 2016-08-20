//
//  CalendarEventDataStore.swift
//  Guidr
//
//  Created by Flatiron School on 8/20/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import Foundation
import EventKit

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
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        switch (status) {
        case EKAuthorizationStatus.NotDetermined: // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.Authorized:
            calendarSetup() //setup the calendar
            break
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
            //TODO: handle this
            // let's send out a nsnotification to the respective controller that the user has 
            // to manually go into settings and enable the calendar
            //The user has to manually grant access
            //What I could do here is to simply
            //some logic to have user open settings
            //                    let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            //                    UIApplication.sharedApplication().openURL(openSettingsUrl!)
            
            //Do a shared method since this functinality gets used twice
            break
            
        }
    }
    
    func calendarSetup() {
        
        // If the app's calendar already exists on the phone, use it
        let calendars = eventStore.calendarsForEntityType(.Event)
        for calendar: EKCalendar in calendars {
            if calendar.title == appName {
                self.calendar = calendar
                return
            }
        }
        
        // Otherwise, create one
        calendar = EKCalendar(forEntityType: .Event, eventStore: eventStore)
        calendar.title = appName
        
        calendar.source = eventStore.sources.filter {
            (source: EKSource) -> Bool in
            source.sourceType.rawValue == EKSourceType.Local.rawValue
            }.first!
        
        do {
            try self.eventStore.saveCalendar(calendar, commit: true)
            
        } catch {
            //WE will use NSNotification to instruct user
            //by opening an Alert on the VC
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
                    
                })
            }
        })
    }

}