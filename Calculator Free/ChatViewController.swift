//
//  ChatViewController.swift
//  Calculator Free
//
//  Created by Isaac Ashwin on 4/9/18.
//  Copyright © 2018 Isaac Ashwin. All rights reserved.
//

import UIKit
import XMPPFramework

class ChatViewController: UIViewController, UITextFieldDelegate {
    var name: String!
    var xmppController: XMPPController!
    var context: NSManagedObjectContext!
    
    var messages: [NSManagedObject] = []
    @IBOutlet weak var lblChatHistory: UILabel!
    @IBOutlet weak var edtMessage: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = name
        xmppController.parent = self
        lblChatHistory.sizeToFit()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        loadChatHistory()
        
        edtMessage.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadChatHistory() {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "h:mm a"
        dateFormatterGet.timeZone = TimeZone(abbreviation: "SGT")
        
        messages = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Messages")
        let predicate = NSPredicate(format: "name == %@", name)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            return false
        }
        let entity = NSEntityDescription.entity(forEntityName: "Messages", in: context)
        let newChat = NSManagedObject(entity: entity!, insertInto: context)
        newChat.setValue(name, forKey: "name")
        newChat.setValue("testuser1", forKey: "sender")
        newChat.setValue(textField.text!, forKey: "body")
        newChat.setValue(Date(), forKey: "receivedOn")
        do {
            try context.save()
            loadChatHistory()
            let message = textField.text!
            let senderJID = XMPPJID(string: (name + "@devostrum.no-ip.info"))
            let msg = XMPPMessage(type: "chat", to: senderJID)
            
            msg.addBody(message)
            xmppController.xmppStream.send(msg)
            textField.text = ""
            textField.resignFirstResponder()
        } catch {
            print("Failed saving")
        }
        
        return true
    }
}
