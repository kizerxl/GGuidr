//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("start loading this bitch up")

        super.layoutSubviews()
        self.setupView()
        allCards = []
        loadedCards = []
        cardContentArray = []
        print("MIDWAY loading this bitch up")
        cardsLoadedIndex = 0
//        self.loadCards()
        print("end loading this bitch up")

    }
    
    convenience init(){
 
        self.init(frame: CGRect.zero)
        
        let screenHeight = UIScreen.mainScreen().bounds.height
        let screenWidth = UIScreen.mainScreen().bounds.width
        self.heightAnchor.constraintEqualToConstant(screenHeight).active = true
        self.widthAnchor.constraintEqualToConstant(screenWidth).active = true

    }
        
        
        
    
    func setupView() -> Void {
        self.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        self.backgroundColor = UIColor.whiteColor()
        
        
        xButton = UIButton(frame: CGRectMake((self.frame.size.width - CARD_WIDTH)/2 + 35, self.frame.size.height/2 + CARD_HEIGHT/2 + 10, 100, 75))
        xButton.setImage(UIImage(named: "xMark"), forState: UIControlState.Normal)
        xButton.addTarget(self, action: "swipeLeft", forControlEvents: UIControlEvents.TouchUpInside)
        
        checkButton = UIButton(frame: CGRectMake(self.frame.size.width/2 + CARD_WIDTH/2 - 85, self.frame.size.height/2 + CARD_HEIGHT/2 + 10, 90, 75))
        checkButton.setImage(UIImage(named: "checkMark"), forState: UIControlState.Normal)
        checkButton.addTarget(self, action: "swipeRight", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(xButton)
        self.addSubview(checkButton)
    }
    
    func createDraggableViewWithDataAtIndex(index: NSInteger) -> CardView {
//        let draggableView = CardView(frame: CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT))
        
        let currentCard = cardContentArray[index]
        
        let draggableView = CardView(title: currentCard.count > 1 ? currentCard[1] : "(no title)",
                                         date: NSDate(),
                                         location: currentCard.count > 2 ? currentCard[2] : "(no location given)",
                                         eventDescription: currentCard.count > 3 ? currentCard[3] : "(no description)")
        
        
    
//        let draggableView = CardView(title: "shit", date: NSDate(), location: "somewhere where there is shit", eventDescription: "lots and lots of shit")
//        draggableView.information.text = exampleCardLabels[index]
        draggableView.delegate = self
        return draggableView
    }
    
    func loadCards() -> Void {
        print("loading cards......")
        print("size of cardContentArray is \(cardContentArray.count)")
        
        if cardContentArray.count > 0 {
            print("starting the official loading of the cards mein")

            let numLoadedCardsCap = cardContentArray.count > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : cardContentArray.count
            for i in 0 ..< cardContentArray.count {
                let newCard: CardView = self.createDraggableViewWithDataAtIndex(i)
                allCards.append(newCard)
                print("All cards count: \(allCards.count)")
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                    print("Loaded cards count: \(loadedCards.count)")

                }
            }
            
            for i in 0 ..< loadedCards.count {
                print("We are in the ACTUAL loading of the cards!!!!!!")
                
                let card1 = loadedCards[i]

                // Put first card above the view; each subsequent card goes below the preceding one
                if i > 0 {
                    print("added a card above the view!")
                    self.insertSubview(card1, belowSubview: loadedCards[i - 1])
                    let card2 = loadedCards[i - 1]
                    card2.translatesAutoresizingMaskIntoConstraints = false
                    card2.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
                    card2.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
                    
                } else {
                    self.addSubview(card1)
                }
                
                card1.translatesAutoresizingMaskIntoConstraints = false
                card1.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
                card1.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
                layoutIfNeeded()
                
            }
            print("Cards loaded: \(cardsLoadedIndex)")
            cardsLoadedIndex! += 1
        }
    }
    
    func cardSwiped(card: UIView) -> Void {

        print("just swiped!!!")

        loadedCards.removeAtIndex(0)
        
        if cardsLoadedIndex < allCards.count {
            print("haven't run out of cards yet")
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        } else {
            print("ran out of cards")
        }
    
    }
    func cardSwipedLeft(card: UIView) -> Void {
        cardSwiped(card)
    }
    func cardSwipedRight(card: UIView) -> Void {
        cardSwiped(card)
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
        print("Getting into the draggable background array add!")
        self.cardContentArray = cardsArray
        print("This is what the cards array looks like: \(self.cardContentArray)")
        self.loadCards()
    }
    

}