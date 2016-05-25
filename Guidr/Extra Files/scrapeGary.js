/*
  This is working correctly. It's parsing the information and I'm getting the right strings from the html elements. What's next:
    -get complete parse of the event with times and description organized 
    -make code cleaner
*/ 

function scapeGary(){
  
  var url = 'http://www.garysguide.com/events';
  var page = UrlFetchApp.fetch(url);
  var doc = Xml.parse(page, true);
  var bodyHtml = doc.html.body.toXmlString();
  doc = XmlService.parse(bodyHtml);
  var root = doc.getRootElement();
  var events = []; //will store events 
  var currentDay; 
  var newEvent = [];
  
  var mainContentBox = getElementsByClassName(root, 'boxx_none');
  var descendants = mainContentBox[0].getDescendants(); 
          
    for(i in descendants){
      
      var currentElement = descendants[i].asElement();
      
      if(currentElement != null){
     
        var classes =  currentElement.getAttribute('class');

        if(classes != null){
        
       //start checking for fblack
                      
           var currentClass = classes.getValue(); 
           
           //Let's set the current day here. The day strings have the fblack class on them 
           if(currentClass == 'fblack'){
                 
                var boldTags = getElementsByTagName(currentElement, 'b');
 
                //This will add a new event to our event array then reset our newEvent array 
                //for storing new event components for a single event (ie title, description)
                
                if(newEvent.length > 0){
                  
                  events.push(newEvent); 
                  newEvent = [];
                
                }

                for(i in boldTags){
                   
                   currentDay = boldTags[i].getText(); 
                   Logger.log('DATE for currrent events is: '+boldTags[i].getText()+'\n\n');
                  
                }
                
                newEvent.push(currentDay); 
           }

         //end checking for fblack
         
         //start checking for ftitle
           
          else if(currentClass == 'ftitle'){
           
           var boldTitle = getElementsByTagName(currentElement, 'b');
              
             //will need to refactor as this executes once...
             for(i in boldTitle) newEvent.push(boldTitle[i]); 
                  
             Logger.log('The title for the event is '+boldTitle[i].getText());
             
            }
         //end checking for ftitle
              
         //start checking for fdescription
           
          else if(currentClass == 'fdescription'){
            
              var boldLocation = getElementsByTagName(currentElement, 'b');
              var fullEventLocation = '';
              
              //will need to refactor as this executes once...
              for(i in boldLocation) fullEventLocation = boldLocation[i].getText();
                
              fullEventLocation = fullEventLocation.concat(currentElement.getText()); 
              Logger.log('the full address is '+fullEventLocation);
              
              newEvent.push(fullEventLocation);
            }
           
        //end checking for fdescription
 
       //start checking for fgray
           
        else if(currentClass == 'fgray'){
        
           Logger.log('The description for the event is '+currentElement.getText()+'\n\n');
           newEvent.push(currentElement.getText());
              
        }
           
        //end checking for fgray

      }
        
  //checks for all classes end here......
    }

  }

   Logger.log('total count for events array is '+events.length); 
   
   return events; 

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

'fbox' - container for the events;
'fboxtitle' - title (ie "EVENT SPOTLIGHT' for the  current container);
'fblack' - is the for the events (ie it will look like May 03: CIO Conference);
'fblacksmall' - gray description right under the title


Event structure: 

  fblack
  fdescription 
  fgray 
  

*/