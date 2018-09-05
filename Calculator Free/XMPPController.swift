//
//  XMPPController.swift
//  Calculator Free
//
//  Created by Isaac Ashwin on 4/9/18.
//  Copyright © 2018 Isaac Ashwin. All rights reserved.
//

import Foundation
import XMPPFramework

enum XMPPControllerError: Error {
    case wrongUserJID
}

class XMPPController: NSObject {
    var xmppStream: XMPPStream
    weak var parent: ChatViewController?
    
    let hostName: String
    let userJID: XMPPJID
    let hostPort: UInt16
    let password: String
    
    init(hostName: String, userJIDString: String, hostPort: UInt16 = 1080, password: String) throws {
        guard let userJID = XMPPJID(string: userJIDString) else {
            throw XMPPControllerError.wrongUserJID
        }
        
        self.hostName = hostName
        self.userJID = userJID
        self.hostPort = hostPort
        self.password = password
        
        // Stream Configuration
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.myJID = userJID
        
        super.init()
        
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    func connect() {
        if !self.xmppStream.isDisconnected {
            return
        }
        
        try! self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
    }
}

extension XMPPController: XMPPStreamDelegate {
    func xmppStreamDidConnect(_ stream: XMPPStream) {
        print("Stream: Connected")
        try! stream.authenticate(withPassword: self.password)
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        self.xmppStream.send(XMPPPresence())
        print("Stream: Authenticated")
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        let from = (message.from)?.user
        let body = (message.body)!
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Messages", in: context)
        let newChat = NSManagedObject(entity: entity!, insertInto: context)
        newChat.setValue(from, forKey: "name")
        newChat.setValue(from, forKey: "sender")
        newChat.setValue(body, forKey: "body")
        newChat.setValue(Date(), forKey: "receivedOn")
        do {
            try context.save()
            parent?.loadChatHistory()
        } catch {
            print("Failed saving")
        }
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        print("Did receive IQ")
        return false
    }
    
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        print("Did send message \(message)")
    }
}
