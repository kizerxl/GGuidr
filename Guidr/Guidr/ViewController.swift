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
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/script.external_request"]
    
    private let service = GTLService()
    let output = UITextView()
    
    // When the view loads, create necessary subviews
    // and initialize the Google Apps Script Execution API service
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            callAppsScript() //replace this with the store 
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    // Calls an Apps Script function to list the folders in the user's
    // root Drive folder.
    func callAppsScript() {
        output.text = "Executing script..."
        let baseUrl = "https://script.googleapis.com/v1/scripts/\(kScriptId):run"
        let url = GTLUtilities.URLWithString(baseUrl, queryParameters: nil)
        
        // Create an execution request object.
        var request = GTLObject()
        request.setJSONValue("scapeGary", forKey: "function")
        
        // Make the API request.
        service.fetchObjectByInsertingObject(request,
                                             forURL: url,
                                             delegate: self,
                                             didFinishSelector: #selector(ViewController.displayResultWithTicket(_:finishedWithObject:error:)))
    }
    
    // Displays the events or an error in the textview
    func displayResultWithTicket(ticket: GTLServiceTicket,
                                 finishedWithObject object : GTLObject,
                                                    error : NSError?) {
        if let error = error {
            // The API encountered a problem before the script
            // started executing.
            showAlert("The API returned the error: ",
                      message: error.localizedDescription)
            return
        }
        
        if let apiError = object.JSON["error"] as? [String: AnyObject] {
            // The API executed, but the script returned an error.
            
            // Extract the first (and only) set of error details and cast as
            // a Dictionary. The values of this Dictionary are the script's
            // 'errorMessage' and 'errorType', and an array of stack trace
            // elements (which also need to be cast as Dictionaries).
            let details = apiError["details"] as! [[String: AnyObject]]
            var errMessage = String(
                format:"Script error message: %@\n",
                details[0]["errorMessage"] as! String)
            
            if let stacktrace =
                details[0]["scriptStackTraceElements"] as? [[String: AnyObject]] {
                // There may not be a stacktrace if the script didn't start
                // executing.
                for trace in stacktrace {
                    let f = trace["function"] as? String ?? "Unknown"
                    let num = trace["lineNumber"] as? Int ?? -1
                    errMessage += "\t\(f): \(num)\n"
                }
            }
            
            // Set the output as the compiled error message.
            output.text = errMessage
        } else {
            // The result provided by the API needs to be cast into the
            // correct type, based upon what types the Apps Script function
            // returns. Here, the function returns an Apps Script Object with
            // String keys and values, so must be cast into a Dictionary
            // (folderSet).
            print("here is the response: \(object.JSON)\n")
            let response = object.JSON["response"] as! [String: AnyObject]
            let events = response["result"] as! [[String]]
   
            //this is from the original google thingy
            var eventsText = ""
            
            if events.count == 0 {
                output.text = "No events found\n"
            } else {
                for event in events {
                    eventsText += "\(event)\n\n"
                }
            }
            
                output.text = eventsText
            
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
        //do some shit
    }
    
    func cardSwipedRight(card: UIView) {
        //do some shit
    }
}