//
//  DirectoryViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/14/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    func beginRefreshingManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: true)
        }
        beginRefreshing()
        sendActions(for: UIControlEvents.valueChanged)
    }
}

class DirectoryViewController: UITableViewController {
    
    var members = [Member]()
    var event : Event?
    var refresh = UIRefreshControl()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            tableView.refreshControl = self.refresh
            refresh.addTarget(self, action: #selector(loadDataFromRefresh), for: .valueChanged)
            print("Directory loaded")
        }
        
        override func viewWillAppear(_ animated: Bool) {
            if let event = event {
                self.navigationItem.title = "\(event.name!) attendees"
            } else {
                self.navigationItem.title = "Directory"
            }
        }
    
        override func viewDidAppear(_ animated: Bool) {
            refresh.beginRefreshingManually()
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return members.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell()//.dequeueReusableCell(withIdentifier: "MembersCell", for: indexPath) as UITableViewCell
            
            var member : Member
            member = members[indexPath.row]
            cell.textLabel?.text = member.name
            
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        }
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Delete the row from the data source
                let collection = KCSCollection.init(from: "Members", of: Member.self)
                let store = KCSAppdataStore(collection: collection, options: nil)
                
                let memberToDelete = members[indexPath.row]
                members.remove(at: indexPath.row)
                _ = store?.remove(memberToDelete, withDeletionBlock: { (deletionDictorNil, error) in
                    if error != nil {
                        //error occurred - add back into the list
                        self.members.insert(memberToDelete, at: indexPath.row)
                        tableView.insertRows(
                            at: [indexPath],
                            with: UITableViewRowAnimation.automatic
                        )
                        //NSLog("Delete failed, with error: %@", error)
                    } else {
                        //delete successful - UI already updated
                        //NSLog("deleted response: %@", deletionDictorNil)
                    }
                    }, withProgressBlock: nil)
                
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
            
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
            
            if let selectedEventCell = sender as? UITableViewCell {
                //let eventViewController = segue.destination as! EventViewController
                //let indexPath = tableView.indexPath(for: selectedEventCell)!
                //let selectedEvent = events[(indexPath.row)]
                //eventViewController.event = selectedEvent
            }
        }
    
        func loadDataFromRefresh() {
            loadData(event: event)
        }
        
        func loadData(event: Event?) {
        
            let collection = KCSCollection.init(from: "Members", of: Member.self)
            let store = KCSAppdataStore(collection: collection, options: nil)
            
            if let event = event {
                _ = store?.loadObject(withID: event.attendees, withCompletionBlock: { (members_list, error) in
                    if let members_list = members_list {
                        self.members = members_list as! [Member]
                        self.tableView.reloadData()
                    }
                    
                    self.refresh.endRefreshing()
                    }, withProgressBlock: nil)
            } else {
                let query = KCSQuery(onField: "groupIdentifier", withExactMatchForValue: KCSUser.active().getValueForAttribute("groupIdentifier") as! String)
                
                _ = store?.query(withQuery:
                    query, withCompletionBlock: { (members_list, error) -> Void in
                        if let members_list = members_list {
                            self.members = members_list as! [Member]
                            self.tableView.reloadData()
                        }
                        
                        self.refresh.endRefreshing()
                    },
                           withProgressBlock: nil
                )

                
        }
    
    }
}
