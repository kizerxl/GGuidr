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

class CardDataStore: NSObject {
    
    var hasContent = false
    var store = []{
        didSet{
            hasContent = self.store.count > 0
        }
    }
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/script.external_request"]
    static let sharedInstance = CardDataStore()
    
    
    private override init(){}
    
    public func getEventsContent(usingService service: GTLService, completion:(result: Bool) -> Void){
        
        let baseUrl = "https://script.googleapis.com/v1/scripts/\(secretKScriptId):run"
        let url = GTLUtilities.URLWithString(baseUrl, queryParameters: nil)
        
        // Create an execution request object.
        let request = GTLObject()
        request.setJSONValue("scapeGary", forKey: "function")
        
        // Make the API request.
         service.fetchObjectByInsertingObject(request,
                                              forURL: url,
                                              delegate: self,
                                              didFinishSelector: #selector(displayResultWithTicket(_:finishedWithObject:error:)))
        
        completion(result: hasContent)
    
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
            print("here is the response: \(object.JSON)\n")
            let response = object.JSON["response"] as! [String: AnyObject]
            self.store = response["result"] as! [[String]]
            
            print("hasContent is \(hasContent)")
    
        }
        
    }

}


