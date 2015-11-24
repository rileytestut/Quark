//
//  InterfaceController.swift
//  Cow-Bell WatchKit Extension
//
//  Created by Maddie Mccarthy on 11/15/15.
//  Copyright © 2015 Spark SC. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation


class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
     
        // Configure interface objects here.
    }
    @IBOutlet  weak var statusTextLabel: WKInterfaceLabel!

    @IBOutlet var name: WKInterfaceButton!

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        super.willActivate()
        
        name.setTitle("Cow Bell")
        
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
            
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func cowbellButton() {
        
        WCSession.defaultSession().sendMessage(["more_cowbell?" : true], replyHandler: nil, errorHandler: nil)
        
    }
    
    //override func setTitle(title: String?) {
   ////     self.statusTextLabel.setText("🐮🔔")
      
  //  }
    
   
    
 //   button.text: "🐮🔔"
    
    
}

extension InterfaceController: WCSessionDelegate
{
    
}



//one interface controller, one button