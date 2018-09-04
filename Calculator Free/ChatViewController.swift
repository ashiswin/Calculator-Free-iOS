//
//  ChatViewController.swift
//  Calculator Free
//
//  Created by Isaac Ashwin on 4/9/18.
//  Copyright © 2018 Isaac Ashwin. All rights reserved.
//

import UIKit
import XMPPFramework

/// View Controller that manages an ongoing chat with a person
class ChatViewController: UIViewController, UITextFieldDelegate {
    /// Username of the person currently being chatted with
    var name: String!
    /// Handle to the XMPP controller instantiated for the session
    var xmppController: XMPPController!
    /// CoreData context
    var context: NSManagedObjectContext!
    
    /// Array to hold loaded messages from CoreData
    var messages: [NSManagedObject] = []
    
    // Interface Builder references
    @IBOutlet weak var lblChatHistory: UILabel!
    @IBOutlet weak var edtMessage: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = name // Set title of nav bar
        xmppController.parent = self
        lblChatHistory.sizeToFit() // Top align label
        
        // Initialize CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        // Load chat history for current chat
        loadChatHistory()
        
        edtMessage.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Function to load chat history with selected user from CoreData model
    func loadChatHistory() {
        // Format dates in the database nicely
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "h:mm a"
        dateFormatterGet.timeZone = TimeZone(abbreviation: "SGT")
        
        // Select messages with current person
        messages = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Messages")
        let predicate = NSPredicate(format: "name == %@", name)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        
        // Load data into array and label
        // TODO: Change to table instead of label
        do {
            let result = try context.fetch(request)
            var text = ""
            for data in result as! [NSManagedObject] {
                messages.append(data)
                text += "[\(data.value(forKey: "sender") as! String) - \(dateFormatterGet.string(from: data.value(forKey: "receivedOn") as! Date))]: \(data.value(forKey: "body") as! String)\n"
                print(data.value(forKey: "body") as! String)
            }
            lblChatHistory.text = text
            lblChatHistory.sizeToFit()
        } catch {
            print("Failed to load chats")
        }
    }
    
    /// Function to send a message when Send is pressed on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Ignore empty message
        if textField.text == "" {
            return false
        }
        
        // Create new CoreData entity for local storage
        let entity = NSEntityDescription.entity(forEntityName: "Messages", in: context)
        let newChat = NSManagedObject(entity: entity!, insertInto: context)
        newChat.setValue(name, forKey: "name")
        newChat.setValue("testuser1", forKey: "sender")
        newChat.setValue(textField.text!, forKey: "body")
        newChat.setValue(Date(), forKey: "receivedOn")
        
        // Perform actual sending
        do {
            // Attempt to save to CoreData before sending actual message
            try context.save()
            
            let message = textField.text!
            let senderJID = XMPPJID(string: (name + "@devostrum.no-ip.info"))
            let msg = XMPPMessage(type: "chat", to: senderJID)
            
            msg.addBody(message)
            xmppController.xmppStream.send(msg)
            
            // Reload chat history
            loadChatHistory()
            
            // Reset message text field
            textField.text = ""
            textField.resignFirstResponder()
        } catch {
            print("Failed saving")
        }
        
        return true
    }
}
