//
//  ViewController.swift
//  Guidr
//
//  Created by Felix Changoo on 5/25/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import GoogleAPIClient
import GTMOAuth2
import UIKit
import EventKit

class ViewController: UIViewController, CalendarDelegate {
    
    private let kKeychainItemName = nameInKeychain
    private let kClientID = secretKClientID
    private let kScriptId = secretKScriptId
    private var dataStore: CardDataStore!
    private var draggableBackground: DraggableViewBackground!
    private var eventsContentArray: [[String]]!
    private var eventStore: EKEventStore!
    private var calendar: EKCalendar!
    private var appName = "Guidr"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/script.external_request"]
    
    private let service = GTLService()
    
    // When the view loads, create necessary subviews
    // and initialize the Google Apps Script Execution API service
    override func viewDidLoad() {
        super.viewDidLoad()

        eventStore = EKEventStore()
        
        dataStore = CardDataStore.sharedInstance
        
//        view.backgroundColor = UIColor.purpleColor()
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
    }
    
    // When the view appears, ensure that the Google Apps Script Execution API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        
        // Make sure we have calendar authorization
        checkCalendarAuthorizationStatus()
        
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            print("just got inside viewdidapppear!!!!!!!")

            //call our data store here and have it return the card content
             dataStore.getEventsContent(usingService: service)
            print("after using the getEventsContent method!!!!")
            NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(ViewController.setupViewWithDraggableView(_:)), name: eventsLoadedNotification, object: nil)
            
            print("just setup the draggable view!")
            print("here is the result of the script!!!: \(dataStore.getEventsContentFromStore())")

            
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    // (Copied from tutorial)
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        switch (status) {
        case EKAuthorizationStatus.NotDetermined: // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.Authorized:
//            if draggableBackground != nil {
//                calendarSetup()
//            }
            calendarSetup() //setup the calendar
            break // Things are in line with being able to show the calendars in the table view
//            loadCalendars() //TODO: change this
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
            //TODO: handle this
            break
            
        }
    }
    
    // Creates the auth controller for authorizing access to Google Apps Script Execution API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: #selector(ViewController.viewController(_:finishedWithAuth:error:))
        )
    }
    
    // Handle completion of the authorization process, and update the Google Apps Script Execution API
    // with the new credentials.
    func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertView(
            title: title,
            message: message,
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        alert.show()
    }
    
    @objc func setupViewWithDraggableView(note: NSNotification) {
        print("started setting up draggable vieww!!!!")
        eventsContentArray = dataStore.getEventsContentFromStore()
        
        print("size of the eventsContentArray is \(eventsContentArray.count)")

//        draggableBackground = DraggableViewBackground(frame: self.view.frame)
        draggableBackground = DraggableViewBackground()
        view.addSubview(draggableBackground)
        draggableBackground.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        draggableBackground.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        draggableBackground.translatesAutoresizingMaskIntoConstraints = false
        view.layoutIfNeeded()
        
        
        draggableBackground.addCardsContent(eventsContentArray)
        draggableBackground.calDelegate = self
        view.addSubview(draggableBackground)
        print("ended setting up draggable vieww!!!!")

    }

    
    func calendarSetup() {
        
        // If the app's calendar already exists on the phone, use it
        let calendars = eventStore.calendarsForEntityType(.Event)
        for calendar: EKCalendar in calendars {
            if calendar.title == appName {
                print("calendar is already made!!!!!")
                self.calendar = calendar
                return
            }
        }
        
        // Otherwise, create one
        calendar = EKCalendar(forEntityType: .Event, eventStore: eventStore)
        calendar.title = appName
        
        calendar.source = eventStore.sources.filter{
            (source: EKSource) -> Bool in
            source.sourceType.rawValue == EKSourceType.Local.rawValue
            }.first!
        
        do {
            try self.eventStore.saveCalendar(calendar, commit: true)

        } catch {
            let alert = UIAlertController(title: "Couldn't create calendar", message: (error as NSError).localizedDescription, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(OKAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        print("MADE the calendar and now we are going to use it!!!!!!")
        
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
            (accessGranted: Bool, error: NSError?) in
            
            if accessGranted == true {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    print("Access granted!!!!!")
                    
                    
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    //some logic to have user open settings
//                    let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
//                    UIApplication.sharedApplication().openURL(openSettingsUrl!)

                })
            }
        })
    }
    
    
    func addEventToCalendar(card:CardView){
        
        //we add the event to the calendar 
        
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = calendar
        newEvent.title = card.title
        newEvent.startDate = card.date
        newEvent.endDate = card.date.dateByAddingTimeInterval(2 * 60 * 60)
        newEvent.notes = card.eventDescription
        newEvent.location = card.location
        
        
        print("The start event date is \(newEvent.startDate)")
        print("The end event date is \(newEvent.endDate)")

        
        do {
            try eventStore.saveEvent(newEvent, span: .ThisEvent)
            print("This was added to the calendar!!!!")
            
        } catch {
            //TODO: handle this somehow if the event does not save.....
            print("WOMP womp womp not added to calendar!!!")

        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}