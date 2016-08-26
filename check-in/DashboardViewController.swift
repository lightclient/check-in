//
//  DashboardViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/16/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    /* -------------------------------------------------------- */
    
    var type : String?
    var events = [Event]()
    var members = [Member]()
    
    var refresh = UIRefreshControl()
    
    @IBOutlet weak var listView: UITableView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countType: UILabel!
    
    /* -------------------------------------------------------- */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make the background blue
        view.backgroundColor = UIColor(red:0.23, green:0.48, blue:0.84, alpha:1.0)
        
        // Set the UITableView delegates
        listView.dataSource = self
        listView.delegate = self
        
        // Make tableview background white
        listView.backgroundColor = .white
        
        // Setup activity wheel
        listView.refreshControl = self.refresh
        refresh.tintColor = .black
        refresh.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        
        // Start a refresh...eventually should figure out a better way
        refresh.beginRefreshingManually()
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let type = type {
            // If we're in the events dashboard
            if type == "events" {
                // Set the related labels
                countLabel.text = "\(events.count)"
                countType.text = events.count == 1 ? "total event" : "total events"
                
            // If we're in the members dashboard
            } else if type == "members" {
                // Set the related labels
                countLabel.text = "\(members.count)"
                countType.text = members.count == 1 ? "total member" : "total members"
            }
            
            // Return the number of rows
            // -- this is in case there are less than 5 members / events
            // -- and we need to display less rows than our max of 5
            return type == "events" ? (events.count < 5 ? events.count : 5) : (members.count < 5 ? members.count : 5)
        }
        
        // If we get here we have a problem
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Name the sections best or worst depeding on whether it is section 0 or 1
        if let type = type {
            if section == 0 {
                return "Best " + (type == "events" ? "Events" : "Members")
            } else if section == 1 {
                return "Worst " + (type == "events" ? "Events" : "Members")
            }
        }

        // ...
        return ""
    }

    // Create a custom label for the section headers
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myLabel = UILabel()
        let cell = DashboardCell()
        myLabel.frame = CGRect(x: 15, y: cell.frame.height / 2, width: 320, height: 20)
        myLabel.font = UIFont(name: "Futura-bold", size: 18)
        myLabel.text = self.tableView(listView, titleForHeaderInSection: section)
        myLabel.textColor = .black
        let myView = UIView()
        myView.addSubview(myLabel)
        return myView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Magic number
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // For some reason if you return 0 it goes back to the default
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath) as! DashboardCell
        
        if let type = type {
            if type == "events" {
                
                var index = indexPath.row
                
                if indexPath.section == 1 {
                    index = events.count - indexPath.row - 1
                }
                
                let event = events[index]
                cell.title.text = event.name
                cell.subtitle.text = event.location
                cell.countLabel.text = "\(event.attendees.count)"
                cell.countType.text = event.attendees.count == 1 ? "attendee" : "attendees"
            } else {
                var index = indexPath.row
                
                if indexPath.section == 1 {
                    index = members.count - indexPath.row - 1
                }
                
                let member = members[index]
                cell.title.text = member.name
                cell.subtitle.text = member.email
                cell.countLabel.text = "\(member.events.count)"
                cell.countType.text = member.events.count == 1 ? "event" : "events"
            }
        }
        return cell
    }

    func loadData() {

        if let type = type {
            if type == "events" {
                let collection = KCSCollection.init(from: "Events", of: Event.self)
                let store = KCSAppdataStore(collection: collection, options: nil)
                
                let query = KCSQuery(onField: "groupIdentifier", withExactMatchForValue: KCSUser.active().getValueForAttribute("groupIdentifier") as! String)
                
                _ = store?.query(withQuery:
                    query, withCompletionBlock: { (events_list, error) -> Void in
                        if let events_list = events_list {
                            // Sucessfully got events list
                            self.events = events_list as! [Event]
                            
                            // Sort the events array alphbetically
                            self.events.sort(by: { (a, b) -> Bool in
                                return a.attendees.count > b.attendees.count
                            })
                            
                            // Reload with new data
                            self.listView.reloadData()
                        }
                        
                        // Done interacting w/ the interwebs...we can turn off the activity wheel
                        self.refresh.endRefreshing()
                    },
                           withProgressBlock: nil
                )
            } else if type == "members" {
                let collection = KCSCollection.init(from: "Members", of: Member.self)
                let store = KCSAppdataStore(collection: collection, options: nil)
                
                let query = KCSQuery(onField: "groupIdentifier", withExactMatchForValue: KCSUser.active().getValueForAttribute("groupIdentifier") as! String)
                
                _ = store?.query(withQuery:
                    query, withCompletionBlock: { (members_list, error) -> Void in
                        if let members_list = members_list {
                            // Sucessfully got events list
                            self.members = members_list as! [Member]
                            
                            // Sort the events array alphbetically
                            self.members.sort(by: { (a, b) -> Bool in
                                return a.events.count > b.events.count
                            })
                            
                            // Reload with new data
                            self.listView.reloadData()
                        }
                        
                        // Done interacting w/ the interwebs...we can turn off the activity wheel
                        self.refresh.endRefreshing()
                    },
                           withProgressBlock: nil
                )
            }
        }
        
    }

    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return UIStatusBarStyle.lightContent }

}
