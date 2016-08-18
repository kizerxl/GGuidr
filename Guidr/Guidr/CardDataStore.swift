//
//  CardDataStore.swift
//  Guidr
//
//  Created by Flatiron School on 6/10/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import Foundation
import GoogleAPIClient
import UIKit

let eventsLoadedNotification = "eventsLoaded"

class CardDataStore: NSObject {
    
    var hasContent = false
    var store:[[String]] = []{
        didSet{
                NSNotificationCenter.defaultCenter().postNotificationName(eventsLoadedNotification, object: nil)
            print("notification sent!!!!!!")
        }
    }
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/script.external_request"]
    static let sharedInstance = CardDataStore()
    
    
    private override init(){}
    
    internal func getEventsContent(usingService service: GTLService) {
        
        //added this for testing 
        // Please remove or make testing false 
        let testing = true
        
        if testing {
            loadTestData() // for testing
        } else {
            let baseUrl = "https://script.googleapis.com/v1/scripts/\(secretKScriptId):run"
            let url = GTLUtilities.URLWithString(baseUrl, queryParameters: nil)
            
            NSNotificationCenter.defaultCenter().postNotificationName(eventsLoadedNotification, object: self)
            
            // Create an execution request object.
            let request = GTLObject()
            request.setJSONValue("scapeGary", forKey: "function")
            
            // Make the API request.
            service.fetchObjectByInsertingObject(request,
                                                 forURL: url,
                                                 delegate: self,
                                                 didFinishSelector: #selector(displayResultWithTicket(_:finishedWithObject:error:)))
        } //here is the last curly brace for the test
    
    }
    
    // Displays the events or an error in the textview
      func displayResultWithTicket(ticket: GTLServiceTicket,
                                 finishedWithObject object : GTLObject,
                                                    error : NSError?) {
        if let error = error {
            // The API encountered a problem before the script
            // started executing.
//            showAlert("The API returned the error: ",
//                      message: error.localizedDescription)
            print("Here is the error: \(error.localizedDescription)")
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
            
        } else {
            // The result provided by the API needs to be cast into the
            // correct type, based upon what types the Apps Script function
            // returns. Here, the function returns an Apps Script Object with
            // String keys and values, so must be cast into a Dictionary
            // (folderSet).
            print("Find this line and uncomment the following one to see the response object with the events.")
//            print("\n\n\n\nhere is the response: \(object.JSON)\n\n\n\n\n")
            let response = object.JSON["response"] as! [String: AnyObject]
            self.store = response["result"] as! [[String]]
            
//            print("\n\n\n----------The real count of the cards is \(self.store.count)----------\n\n\n")
            
        }
        
    }
    
    internal func getEventsContentFromStore() -> [[String]] {
        return self.store
    }
    
    //this is to load test data in case the site is down 
    //as of 8/13/16 this was the case 
//    GAry JSON sturcture - length is 6 or 7
//    0 - Date
//    1 - Name of event
//    2 - Location/Address
//    3 - event description
//    4 - url of event
//    5 - price of event
//    6 - time of event 

    
    func loadTestData() {
        let event1 = ["8/15/16", "Java Mondays", "Somewhere over the rainbow", "Some really cool event about Java", "http://wwww.google.com", "FREE", "5:00pm"]
        let event2 = ["8/20/16", "Javascript Day", "Somewhere over the rainbow Pt2", "JS all JS all the time!", "http://wwww.google.com", "$30000", "10:00pm"]
        let event3 = ["8/24/16", "Hidden Dragon Covention", "Place unknown", "Ninja coder event.", "http://wwww.google.com", "Pricy", "3:00pm"]
        let event4 = ["8/27/16", "New Event Man", "Cool Place duh!", "So, let's uh make up something here..", "http://wwww.google.com", "Ballin", "1:00pm"]
        store = [event1, event2, event3, event4]
        
    }
    
}


