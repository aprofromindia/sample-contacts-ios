//
//  ViewController.swift
//  HelloContacts
//
//  Created by Choudhury, Apratim (201) on 19/01/2017.
//  Copyright © 2017 Apro. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching{
    
    var contacts = [APCContact]()
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let store = CNContactStore()
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            store.requestAccess(for: .contacts, completionHandler: {[weak self]
                authorized, error in
                if authorized{
                    self?.retrieveContacts(fromStore: store)
                }
            })
        }else if CNContactStore.authorizationStatus(for: .contacts) == .authorized{
            retrieveContacts(fromStore: store)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func retrieveContacts(fromStore store: CNContactStore) {
        let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor,
                           CNContactFamilyNameKey as CNKeyDescriptor,
                           CNContactImageDataKey as CNKeyDescriptor,
                           CNContactImageDataAvailableKey as CNKeyDescriptor]
        
        let containerID = store.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerID)
        contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch).map{
            contact in
            return APCContact(contact: contact)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        let contact = contacts[indexPath.row]
        cell.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        
        contact.fetchImageIfNeeded()
        
        if let image = contact.image {
            cell.imageView?.image = image
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for path in indexPaths{
            let contact = contacts[path.row]
            contact.fetchImageIfNeeded()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            contacts.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let contact = contacts.remove(at: sourceIndexPath.row)
        contacts.insert(contact, at: destinationIndexPath.row)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        let alertC = UIAlertController(title: "Contact tapped", message: "You tapped \(contact.givenName)",
            preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler:
            { handler in tableView.deselectRow(at: indexPath, animated: true)})
        
        alertC.addAction(dismissAction)
        present(alertC, animated: true, completion: nil)
    }
}
