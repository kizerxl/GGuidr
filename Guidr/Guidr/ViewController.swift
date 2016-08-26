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
import Darwin

class ViewController: UIViewController {
    
    private let kKeychainItemName = nameInKeychain
    private let kClientID = secretKClientID
    private let kScriptId = secretKScriptId
    private var dataStore: CardDataStore!
    private var draggableBackground: DraggableViewBackground!
    private var eventsContentArray: [[String]] = []
    private var loadSplash = true
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/script.external_request"]
    
    private let service = GTLService()
    
    // When the view loads, create necessary subviews
    // and initialize the Google Apps Script Execution API service
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.sharedAlert(_:)), name: errorNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.sharedAlert(_:)), name: settingsNotification, object: nil)
        
        view.backgroundColor = UIColor(red: 134/255, green: 36/255, blue: 27/255, alpha: 1)
        dataStore = CardDataStore.sharedInstance
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
        
        // start gary splash here.......
        if loadSplash {
            loadSplash = false
            loadSplashScreen()
        }
    
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            
            //call our data store here and have it return the card content
             dataStore.getEventsContent(usingService: service)  
            
            NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(ViewController.setupViewWithDraggableView(_:)), name: eventsLoadedNotification, object: nil)
//            endSplashScreen() // for testing <--- please delete 
            
        } else {
            endSplashScreen()
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
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
        
        if error != nil {
            service.authorizer = nil
            NSNotificationCenter.defaultCenter().postNotificationName(errorNotification, object: self)
            
            return
        }

        service.authorizer = authResult
        
        dismissViewControllerAnimated(true) {
            self.loadSplashScreen()
        }
    }
    
    func sharedAlert(notification: NSNotification) {
        //put the logic in here that will display the respective message for the right sceanrio
        let alertController: UIAlertController!
        var title = "insert something here for now..."
        var message = "random stuff goes here"

        let tryAgainAction = UIAlertAction(title: "Again?", style: .Default) { (action) in
            self.dataStore.getEventsContent(usingService: self.service)
            self.loadSplashScreen() //relaunch Splash or replace with Spinner as alternative...
        }
        
        let exitAction = UIAlertAction(title: "Exit", style: .Destructive) { (action) in
            exit(0)
        }
        
        switch notification.name {
            case errorNotification:
                title = "Error"
                message = "Seems like either your internet said goodbye\n or we are having some technical difficulties"
                print("Creating an error alert!")
                alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alertController.addAction(tryAgainAction)
                alertController.addAction(exitAction)
                presentViewController(alertController, animated: false, completion: nil)
            
            case settingsNotification:
                title = "Fix Settings"
                message = "We need to fix your settings for calendar usage!\n Click Settings > Privacy > Calendars and have the slider set to the yes position.\n"
                print("Creating a settings alert!!!")
                alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alertController.addAction(exitAction)
                presentViewController(alertController, animated: false, completion: nil)
            
            default: break //do nada
        }
        
    }
    
    @objc func setupViewWithDraggableView(note: NSNotification) {
        
        // If events array is empty, set it up from the data store
        if eventsContentArray.count == 0 {
            
            setupNavBar()
            
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
            
            //make Splash screen go bye bye
            endSplashScreen()
        }
    
    }
    
    func setupNavBar() {
        
        //title image
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
    
    func loadSplashScreen() {
        navigationController?.pushViewController(SplashScreen(), animated: false)
        navigationController?.navigationBarHidden = true
    }
    
    func endSplashScreen() {
        if navigationController?.topViewController is SplashScreen {
            (navigationController?.topViewController as! SplashScreen).animate = false
            navigationController?.popViewControllerAnimated(false)
            navigationController?.navigationBarHidden = false
        }
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