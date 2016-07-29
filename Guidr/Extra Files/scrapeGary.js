/*
  This is working correctly up to 99%. It's missing one event. What's next: 
    -figure out how to get lone event (very last one)
    -make code cleaner
    -refactor datastructure for events 
    
  5/27/16 
    -Adding additional comments 
    -Refactor code to better present event information 
    
  7/29/16 
    -Adding additional comments
    -Added new methods to filter for price, date of events 
    -Scraper now gets url, price and date of events  
    -massive clean up of junk code 
*/ 

function scapeGary() {
  
  var url = 'http://www.garysguide.com/events';
  var page = UrlFetchApp.fetch(url);
  var doc = Xml.parse(page, true);
  var bodyHtml = doc.html.body.toXmlString();
  doc = XmlService.parse(bodyHtml);
  var root = doc.getRootElement();
  var events = []; //will store events 
  var currentDay; 
  var newEvent = [];
  var textFilters = ["am","pm","$","Free"];
  var currentElmStr = "";
  var filteredStrings = [];
  var currentUrl; 
   
  
  var mainContentBox = getElementsByClassName(root, 'boxx_none');          //Each content area events has the class 'boxx_none'
  var descendants = mainContentBox[0].getDescendants();                    //Since we are using the getDescendants method it will return an array but there's only 1 element with boxx_none
    
    //Iterating through the different elements contained in the single content area aka mainContentBox
    for(i in descendants) {
      
      var currentElement = descendants[i].asElement(); //the current element in the main content box 
      
      //these are just checks to see which class is on the current element
      //if the current element matches the class then the respective logic is done for that element with the class 
      if(currentElement != null) {
     
        var classes =  currentElement.getAttribute('class');

        if(classes != null) {
        
       //start checking for fblack
                      
           var currentClass = classes.getValue(); 
           
           //Let's set the current date here. The date strings have the fblack class on them 
           if(currentClass == 'fblack') {
                 
                var boldTags = getElementsByTagName(currentElement, 'b');
 
                //This will add a new event to our event array then reset our newEvent array 
                //for storing new event components for a single event (ie title, description
               
                for(i in boldTags) currentDay = boldTags[i].getText();
           }

         //end checking for fblack
         
         //start checking for ftitle
           
          else if(currentClass == 'ftitle') {
           
               if(newEvent.length > 0) {
                 newEvent.push(currentUrl); //add current URL to the end of the current Event array right before addding.....
                 
                 //....the time then price respectively 
                 if(filteredStrings.length >= 2) {
                   for(i = 0; i < 2; i++) {
                    var currentVal = filteredStrings.shift();
                    newEvent.push(currentVal); 
                  }
               }  
                  events.push(newEvent); 
                  newEvent = [];            //we 'reset' by just making a new array for the next event
              }
                
           newEvent.push(currentDay); 
           
           var boldTitle = getElementsByTagName(currentElement, 'b');
           var linksMoreInfo = getElementsByTagName(currentElement, 'a');
              
             //will need to refactor as this executes once...
             for(i in boldTitle) newEvent.push(boldTitle[i].getText());
             for(i in linksMoreInfo) currentUrl = linksMoreInfo[i].getAttribute("href").getValue(); // get the URL for the current event 
       }
         //end checking for ftitle
              
         //start checking for fdescription
           
          else if(currentClass == 'fdescription') {
              var boldLocation = getElementsByTagName(currentElement, 'b');
              var fullEventLocation = '';
              
              //will need to refactor as this executes once...
              for(i in boldLocation) fullEventLocation = boldLocation[i].getText();
              
              fullEventLocation = fullEventLocation.concat(currentElement.getText());               
              newEvent.push(fullEventLocation);
            }
           
        //end checking for fdescription
 
       //start checking for fgray
       
        else if(currentClass == 'fgray') {
          newEvent.push(currentElement.getText());
        }
           
        //end checking for fgray

      }
        
  //checks for all classes end here......
  
     //checks to see if the current element is a time of day or price ie am, pm, Free or price value 
     else if(classes === null) {
        currentElmStr = currentElement.getText(); 
        
        if(typeof(currentElmStr) === 'string') {
         
          for(i in textFilters) {
           if((textFilters[i] == currentElmStr) || containsFilter(currentElmStr, textFilters[i])) {
             filteredStrings.push(currentElmStr);
             break;
           }
          }
        }
     
      }
    }

 }

   //Loop through this to see the events 
   for(i in events) {
     Logger.log("here is event number "+i+" :"+events[i]+"  \n\n");
   }
   return events; 

}

function containsFilter(element, filter) { 
  var lttrs = element.split("");
  var strLength = element.length; 
  var numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
  //check for time
  if((lttrs.length == 6 || lttrs.length == 7) && (lttrs[1] == ":" || lttrs[2] == ":")) {
      var timeOfDay = element.substr(strLength - 2, strLength - 1); 
      return timeOfDay == filter; 
  } 
  //check for price
  else {
    var result = lttrs.indexOf(filter);
    if(lttrs[0] == filter) { //assuming the filter is '$'
       for(i = 1; i < lttrs.length; i++) {
         if(numbers.indexOf(lttrs[i]) == -1) return false; 
       }
       return true; 
     } 
  }
  return false; 
}

function getElementsByClassName(element, classToFind) {  
  var data = [];
  var descendants = element.getDescendants();
  descendants.push(element);  
  for(i in descendants) {
    var elt = descendants[i].asElement();
    if(elt != null) {
      var classes = elt.getAttribute('class');
      if(classes != null) {
        classes = classes.getValue();
        if(classes == classToFind) data.push(elt);
        else {
          classes = classes.split(' ');
          for(j in classes) {
            if(classes[j] == classToFind) {
              data.push(elt);
              break;
            }
          }
        }
      }
    }
  }
  return data;
}

function getElementsByTagName(element, tagName) {  
  var data = [];
  var descendants = element.getDescendants();  
  for(i in descendants) {
    var elt = descendants[i].asElement();     
    if( elt !=null && elt.getName()== tagName) data.push(elt);      
  }
  return data;
}

/*

Some CSS classes from the page's DOM:

'boxx_none - main container with the events content'
'fbox' - container for the events but we actually don't need to use it for our purposes...
'fboxtitle' - title (ie "EVENT SPOTLIGHT" for the  current container -- same applies to those dates above the table);
'fblack' - is the event date for the events (ie it will look like May 03: CIO Conference);
'fblacksmall' - gray description right under the title 


Event structure: 

  fblack
  fdescription 
  fgray 
  

*/