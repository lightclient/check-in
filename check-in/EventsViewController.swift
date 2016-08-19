//
//  FirstViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/12/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
}

class EventsViewController: UITableViewController {

    var events = [Event]()

    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Events loaded")

        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.23, green:0.48, blue:0.84, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tableView.refreshControl = self.refresh
        refresh.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {

    }

    override func viewDidAppear(_ animated: Bool) {
        refresh.beginRefreshingManually()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventsCell", for: indexPath)
        
        var event : Event
        event = events[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = "\(event.attendees.count) " + (event.attendees.count == 1 ? "attendee" : "attendees")
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let collection = KCSCollection.init(from: "Events", of: Event.self)
            let store = KCSAppdataStore(collection: collection, options: nil)
            
            let eventToDelete = events[indexPath.row]
            events.remove(at: indexPath.row)
            _ = store?.remove(eventToDelete, withDeletionBlock: { (deletionDictorNil, error) in
                if error != nil {
                    //error occurred - add back into the list
                    self.events.insert(eventToDelete, at: indexPath.row)
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
            let eventViewController = segue.destination as! EventViewController
            let indexPath = tableView.indexPath(for: selectedEventCell)!
            let selectedEvent = events[(indexPath.row)]
            eventViewController.event = selectedEvent
        }
    }
    
    func loadData() {
        let collection = KCSCollection.init(from: "Events", of: Event.self)
        let store = KCSAppdataStore(collection: collection, options: nil)
        
        let query = KCSQuery(onField: "groupIdentifier", withExactMatchForValue: KCSUser.active().getValueForAttribute("groupIdentifier") as! String)
        
        _ = store?.query(withQuery:
            query, withCompletionBlock: { (events_list, error) -> Void in
                if let events_list = events_list {
                    self.events = events_list as! [Event]
                    self.tableView.reloadData()
                }
                self.refresh.endRefreshing()
            },
                   withProgressBlock: nil
        )
    }
}

