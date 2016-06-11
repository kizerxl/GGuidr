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

class ViewController: UIViewController, DraggableViewDelegate {
    
    private let kKeychainItemName = nameInKeychain
    private let kClientID = secretKClientID
    private let kScriptId = secretKScriptId
    private var dataStore: CardDataStore!
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/script.external_request"]
    
    private let service = GTLService()
    
    // When the view loads, create necessary subviews
    // and initialize the Google Apps Script Execution API service
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataStore = CardDataStore.sharedInstance
        
        view.backgroundColor = UIColor.blackColor()
        
        // TESTING THE CARD VIEW THING
        let fakeCard = CardView.init(title: "The Event", date: NSDate(), location: "My butthole", eventDescription: "This is an event where an event will take place")
        view.addSubview(fakeCard)
        fakeCard.translatesAutoresizingMaskIntoConstraints = false
        fakeCard.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        fakeCard.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        view.layoutIfNeeded()
        
        // END TEST
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
    fakeCard.delegate = self
        
    }
    
    // When the view appears, ensure that the Google Apps Script Execution API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            
            //call our data store here and have it return the card content
             dataStore.getEventsContent(usingService: service, completion: { (result) in
                
                if result {
                    print("\n\n\nWe got the card contents!!!!!!!")
                }
                
                else{
                    //put a loading icon here while the cards content gets loaded or something...
                    print("Shit doesn't work")
                }
             })
        } else {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cardSwipedLeft(card: UIView) {
        //place logic for adding card event here
    }
    
    func cardSwipedRight(card: UIView) {
        //place logic for adding card event here

    }
}