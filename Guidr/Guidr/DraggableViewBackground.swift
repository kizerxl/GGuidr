//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit
import EventKit

class DraggableViewBackground: UIView, DraggableViewDelegate {
    var cardContentArray: [[String]]!
    var allCards: [CardView]!
    
    let MAX_BUFFER_SIZE = 2
    let CARD_HEIGHT: CGFloat = 386
    let CARD_WIDTH: CGFloat = 290
    
    var cardsLoadedIndex: Int!
    var loadedCards: [CardView]!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var xButton: UIButton!
    var buttonView: ButtonView!
    var calendarOfCurrentYear: NSCalendar!
    var currentDate: NSDate!
    var currentMonth: Int!
    var currentYear: Int!
    var calEventDataStore: CalendarEventDataStore!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        super.layoutSubviews()
        self.setupView()
        self.setupDateChecking()
        allCards = []
        loadedCards = []
        cardContentArray = []
        cardsLoadedIndex = 0
        calEventDataStore = CalendarEventDataStore.sharedInstance //get the shared Calendar Event store
        self.loadCards()

    }
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }

    func setupView() -> Void {
        buttonView = ButtonView()
        addSubview(buttonView)
        addButtonViewConstraints()
        buttonView.checkButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), forControlEvents: UIControlEvents.TouchUpInside)
        buttonView.xButton.addTarget(self, action: #selector(DraggableViewBackground.swipeLeft), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func createDraggableViewWithDataAtIndex(index: NSInteger) -> CardView {
        
        // NEW APPROACH
        // 1) WE initialize an Event object.
                // (Write initializer that sets all the properties, and code here calling it)
        // 2) We initialize a cardview passing in the event object:     CardView(event: event1)
        // 3) In CardView's init, it uses the properties of the Event object to set up its views/labels
        
        let currentCard = cardContentArray[index]
        
//        let draggableView = CardView(title: currentCard.count > 1 ? currentCard[1] : "(no title)",
//                                         date: formatDate(currentCard[0]),
//                                         location: currentCard.count > 2 ? currentCard[2] : "(no location given)",
//                                         eventDescription: currentCard.count > 3 ? currentCard[3] : "(no description)")
        let draggableView = CardView(event: currentCard)
        draggableView.delegate = self
        
        return draggableView
    }
    
    func loadCards() -> Void {
        
        if cardContentArray.count > 0 {

            let numLoadedCardsCap = cardContentArray.count > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : cardContentArray.count
            for i in 0 ..< cardContentArray.count {
                let newCard: CardView = self.createDraggableViewWithDataAtIndex(i)
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)

                }
            }
            
            for i in 0 ..< loadedCards.count {
                
                let card1 = loadedCards[i]

                // Put first card above the view; each subsequent card goes below the preceding one
                if i > 0 {
                    self.insertSubview(card1, belowSubview: loadedCards[i - 1])
                } else {
                    self.addSubview(card1)
                }
                
                addCorrectConstraints(card1)
                
                layoutIfNeeded()
                
            }
            cardsLoadedIndex! += 1
        }
    }
    
    func cardSwiped(card: CardView) -> Void {
        loadedCards.removeAtIndex(0)
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            let card1 = loadedCards[MAX_BUFFER_SIZE - 1]
            self.insertSubview(card1, aboveSubview: self)
            self.insertSubview(card1, belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
            addCorrectConstraints(card1)
            
            layoutIfNeeded()

        }
    
    }
    
    func cardSwipedLeft(card: CardView) -> Void {
        cardSwiped(card)
        // Add the event to the notGoingEvent array of the shared store
        let event = createCalendarEvent(card)
        calEventDataStore.notGoingEvents.append(event)
    }
    
    func cardSwipedRight(card: CardView) -> Void {
        cardSwiped(card)
        
        //Add the event to the goingEvent array of the shared store
        // Add the event to the calendar
        let event = createCalendarEvent(card)
        do {
            try calEventDataStore.eventStore.saveEvent(event, span: .ThisEvent)
            
        } catch {
            print("\n\nProblem: event couldn't be added to the calendar\n\n")
        }
    
    }
    
    func swipeRight() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: CardView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeRight)
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.rightClickAction()
        print("Swipped right!!!!!!")
    }
    
    func swipeLeft() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: CardView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeLeft)
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.leftClickAction()
    }
    
    internal func addCardsContent(cardsArray: [[String]]) {
        self.cardContentArray = cardsArray
        self.loadCards()
    }
    
    
    private func formatDate(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d" /* find out and place date format from http://userguide.icu-project.org/formatparse/datetime */
        var date = dateFormatter.dateFromString(dateString)
        
        //correct date with correct year
        date = correctYearForDate(date!)
        
        return date!
    }
    
    private func setupDateChecking() {
        currentDate = NSDate()
        calendarOfCurrentYear = NSCalendar.currentCalendar()
        
        let components = calendarOfCurrentYear.components([.Month, .Year], fromDate: currentDate)
        
        currentMonth = components.month
        currentYear = components.year
    }
    
    private func correctYearForDate(eventDate: NSDate) -> NSDate {
        var correctYear = currentYear
        var newDate: NSDate!
        
        let components = calendarOfCurrentYear.components([.Month, .Day, .Year], fromDate: eventDate)
        let eventMonth = components.month
    
        if eventMonth < currentMonth {
            correctYear! += 1 //this is one year up
        }
        
        components.setValue(correctYear, forComponent: .Year)
        newDate = calendarOfCurrentYear.dateFromComponents(components)
        
        
        return newDate
    }
    
    //helper method for setting constraints on the passed in card view
    func addCorrectConstraints(card: CardView) {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 10).active = true
        card.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -10).active = true
        card.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 5).active = true
        card.heightAnchor.constraintEqualToAnchor(self.heightAnchor, constant: -150).active = true
    }
    
    //helper method for setting constraints on the buttonSet (aka ButtonView)
    func addButtonViewConstraints() {
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        buttonView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        buttonView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        buttonView.heightAnchor.constraintEqualToConstant(100).active = true
    }
    
    //pass in a cardView and get back a EKEvent object
    func createCalendarEvent(card: CardView) -> EKEvent {
        let cardDate = formatDate(card.eventDate.text!)
        
        let newEvent = EKEvent(eventStore: calEventDataStore.eventStore)
        newEvent.calendar = calEventDataStore.calendar
        newEvent.title = card.eventTitle.text!
        newEvent.startDate = cardDate
        newEvent.endDate = cardDate.dateByAddingTimeInterval(2 * 60 * 60)
        newEvent.notes = card.eventDesc.text!
        newEvent.location = card.eventAddress.text!
        
        return newEvent
    }

}