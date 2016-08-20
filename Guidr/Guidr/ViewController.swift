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

class ViewController: UIViewController, SplashDelegate {
    
    private let kKeychainItemName = nameInKeychain
    private let kClientID = secretKClientID
    private let kScriptId = secretKScriptId
    private var dataStore: CardDataStore!
    private var draggableBackground: DraggableViewBackground!
    private var eventsContentArray: [[String]] = []
//    private var eventStore: EKEventStore!
//    private var calendar: EKCalendar!
//    private var appName = "Guidr"
    private var splashScreen: SplashScreen!
    private var loadSplash = true
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/script.external_request"]
    
    private let service = GTLService()
    
    // When the view loads, create necessary subviews
    // and initialize the Google Apps Script Execution API service
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
//        eventStore = EKEventStore()
        
        dataStore = CardDataStore.sharedInstance
        
        //TODO: request the CalendarStore here and ask for auth <-------- important 
        CalendarEventDataStore.sharedInstance.checkCalendarAuthorizationStatus()
        
        
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
        
        //Check for calendar authorization first!
        CalendarEventDataStore.sharedInstance.checkCalendarAuthorizationStatus()

        // start gary splash here.......
        if loadSplash {
            loadSplash = false
            splashScreen = SplashScreen()
            splashScreen.splashDelegate = self
            presentViewController(splashScreen, animated: false, completion: nil)
        }
        
        // Make sure we have calendar authorization
//        checkCalendarAuthorizationStatus()
        
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            
            //call our data store here and have it return the card content
             dataStore.getEventsContent(usingService: service)  
            
            NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(ViewController.setupViewWithDraggableView(_:)), name: eventsLoadedNotification, object: nil)
//            print("here is the result of the script!!!: \(dataStore.getEventsContentFromStore())")
//            splashScreen.splashDelegate.endSplashScreen(splashScreen) //added this for testing, please delete
            
        } else {
            splashScreen.splashDelegate.endSplashScreen(splashScreen)
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
//    // (Copied from tutorial)
//    func checkCalendarAuthorizationStatus() {
//        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
//        
//        switch (status) {
//        case EKAuthorizationStatus.NotDetermined: // This happens on first-run
//            requestAccessToCalendar()
//        case EKAuthorizationStatus.Authorized:
//            calendarSetup() //setup the calendar
//            break // Things are in line with being able to show the calendars in the table view
////            loadCalendars() //TODO: change this
//        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
//            //TODO: handle this
//            break
//            
//        }
//    }
    
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
        
        // If events array is empty, set it up from the data store
        if eventsContentArray.count == 0 {
            
            eventsContentArray = dataStore.getEventsContentFromStore()
            
            // Create draggable background (containing the card and the X and check buttons)
            draggableBackground = DraggableViewBackground() // <-- the initializer sets the height and width anchors to be the size of screen.
    
            view.addSubview(draggableBackground)
            // Position constraints
            draggableBackground.translatesAutoresizingMaskIntoConstraints = false
            draggableBackground.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
            draggableBackground.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
            draggableBackground.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
            draggableBackground.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
            
            draggableBackground.backgroundColor = UIColor(red: 134/255, green: 36.0/255, blue: 27.0/255, alpha: 1)
            
            view.layoutIfNeeded() 
            
            // Create a card for each event and add the cards to draggable view
            draggableBackground.addCardsContent(eventsContentArray) 
//            draggableBackground.calDelegate = self 
            
            // When setup is done, make the splash screen go away
            splashScreen.splashDelegate.endSplashScreen(splashScreen)
        }
    
    }

    
//    func calendarSetup() {
//        
//        // If the app's calendar already exists on the phone, use it
//        let calendars = eventStore.calendarsForEntityType(.Event)
//        for calendar: EKCalendar in calendars {
//            if calendar.title == appName {
//                self.calendar = calendar
//                return
//            }
//        }
//        
//        // Otherwise, create one
//        calendar = EKCalendar(forEntityType: .Event, eventStore: eventStore)
//        calendar.title = appName
//        
//        calendar.source = eventStore.sources.filter{
//            (source: EKSource) -> Bool in
//            source.sourceType.rawValue == EKSourceType.Local.rawValue
//            }.first!
//        
//        do {
//            try self.eventStore.saveCalendar(calendar, commit: true)
//
//        } catch {
//            let alert = UIAlertController(title: "Couldn't create calendar", message: (error as NSError).localizedDescription, preferredStyle: .Alert)
//            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//            alert.addAction(OKAction)
//            
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
//        
//        
//    }
//    
//    func requestAccessToCalendar() {
//        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
//            (accessGranted: Bool, error: NSError?) in
//            
//            if accessGranted == true {
//                dispatch_async(dispatch_get_main_queue(), {
//                    
//                })
//            } else {
//                dispatch_async(dispatch_get_main_queue(), {
//                    //some logic to have user open settings
////                    let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
////                    UIApplication.sharedApplication().openURL(openSettingsUrl!)
//
//                })
//            }
//        })
//    }
    
    
//    func addEventToCalendar(card:CardView){
//        
//        // Add the event to the user's iPhone calendar
//        
//        let newEvent = EKEvent(eventStore: eventStore)
//        newEvent.calendar = calendar
//        newEvent.title = card.eventTitle.text!
//        newEvent.startDate = card.date
//        newEvent.endDate = card.date.dateByAddingTimeInterval(2 * 60 * 60)
//        newEvent.notes = card.eventDesc.text!
//        newEvent.location = card.eventAddress.text!
//        
//        do {
//            try eventStore.saveEvent(newEvent, span: .ThisEvent)
//            
//        } catch {
//            //TODO: handle this somehow if the event does not save.....
//            print("\n\nProblem: event couldn't be added to the calendar\n\n")
//
//        }
//        
//        
//    }
    
    func endSplashScreen(splash: UIViewController) {
        splash.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func setupNavBar() {
        
        //title image
        let nav = self.navigationController?.navigationBar
        nav?.setBackgroundImage(UIImage(named: "bgHeader"), forBarMetrics: UIBarMetrics.Default)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "garyHeader1")
        imageView.image = image
    
        //set title
        navigationItem.titleView = imageView
        
        //add left button
        let leftButton: UIButton = UIButton(type: UIButtonType.Custom)
        leftButton.setImage(UIImage(named: "settingsImg"), forState: .Normal)
        leftButton.frame = CGRectMake(0, 0, 40, 30)
        leftButton.imageView!.contentMode = .ScaleAspectFit;
        leftButton.contentHorizontalAlignment = .Left
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        leftButton.addTarget(self, action: #selector(settingsTapped), forControlEvents: UIControlEvents.TouchUpInside)
        
        //add right button 
        let rightButton: UIButton = UIButton(type: UIButtonType.Custom)
        rightButton.setImage(UIImage(named: "calendarImg"), forState: .Normal)
        rightButton.frame = CGRectMake(0, 0, 40, 30)
        rightButton.imageView!.contentMode = .ScaleAspectFit;
        rightButton.contentHorizontalAlignment = .Right
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: #selector(calendarTapped), forControlEvents: UIControlEvents.TouchUpInside)
        
        //assign left and right buttons 
        self.navigationItem.leftBarButtonItem  = leftBarButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        //set the text properties of the text on the bar throughout 
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func settingsTapped() {
        print("settings tapped!!!!!")
        self.navigationController!.pushViewController(SettingsTableVC(), animated: true)
    }
    
    func calendarTapped() {
        print("calendar tapped!!!!!")
        self.navigationController!.pushViewController(CalendarVC(), animated: true)

    }
    
}