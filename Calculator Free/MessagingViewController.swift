//
//  MessagingViewController.swift
//  Calculator Free
//
//  Created by Isaac Ashwin on 4/9/18.
//  Copyright © 2018 Isaac Ashwin. All rights reserved.
//

import UIKit
import CoreData
import InitialsImageView

class MessagingViewController: UITableViewController {
    /// Handle to XMPP controller instance for current session
    var xmppController: XMPPController?
    
    /// Array to hold all people chatting with
    var chats: [String] = []
    /// CoreData context
    var context: NSManagedObjectContext!
    
    /// Selected username to pass on to ChatViewController
    var selectedName: String = ""
    
    // Interface Builder references
    @IBOutlet var tblChats: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Attempt connection to Jabber server
        do {
            try self.xmppController = XMPPController(hostName: "devostrum.no-ip.info",
                                                                         userJIDString: "testuser1@devostrum.no-ip.info",
                                                                         password: "pass123")
            self.xmppController!.connect()
        } catch {
            print("Something went wrong")
        }
        
        // Configure chat buddy table
        tblChats.delegate = self
        tblChats.dataSource = self
        tblChats.tableFooterView = UIView(frame: .zero)
        tblChats.tableFooterView?.isHidden = true
        
        // Initialize CoreData session
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        // Load chat buddies
        loadChats()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Function to load chat buddies from CoreData
    func loadChats() {
        chats = [] // Clear array
        
        // Select all chat buddies
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chats")
        request.returnsObjectsAsFaults = false
        
        // Loop through results and add to array
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                chats.append((data.value(forKey: "name") as! String))
            }
            tblChats.reloadData()
        } catch {
            print("Failed to load chats")
        }
    }
    
    /// Function to add a new buddy to chat with
    @IBAction func addBuddy(_ sender: Any) {
        // Create alert with textfield
        let alert = UIAlertController(title: "Add Chat", message: "Add a new chat buddy using their username", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = ""
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (action) -> Void in
            if let textField = alert?.textFields![0] {
                // Ignore empty entry
                if textField.text! == "" {
                    return
                }
                
                // TODO: Check for validity
                
                // Create new CoreData entity and save
                let entity = NSEntityDescription.entity(forEntityName: "Chats", in: self.context)
                let newChat = NSManagedObject(entity: entity!, insertInto: self.context)
                newChat.setValue((textField.text)!, forKey: "name")
                do {
                    try self.context.save()
                    self.loadChats()
                } catch {
                    print("Failed saving")
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /////////////////////////////////////////////
    // UITableViewDelegate Section             //
    /////////////////////////////////////////////
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celChat") as! ChatTableViewCell
        
        cell.lblName.text = chats[indexPath.row]
        cell.imgName.setImageForName(string: chats[indexPath.row], backgroundColor: nil, circular: true, textAttributes: nil)
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedName = chats[indexPath.row]
        
        performSegue(withIdentifier: "segChat", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Set references in ChatViewController
        if let vc = segue.destination as? ChatViewController {
            vc.name = selectedName
            vc.xmppController = xmppController
        }
    }
}
