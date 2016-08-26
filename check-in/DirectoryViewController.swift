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
    
    var membersDictionary : [String:[Member]] = [:]
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map( { String($0) })
    var sectionHeaders = NSMutableOrderedSet()
    var rowCountInSectionHeaders = [Int]()
    
    var event : Event?
    var refresh = UIRefreshControl()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.23, green:0.48, blue:0.84, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders.object(at: section) as! String
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let letter = sectionHeaders.object(at: section)
        let membersForLetter = membersDictionary[letter as! String]
        return membersForLetter!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()//.dequeueReusableCell(withIdentifier: "MembersCell", for: indexPath) as UITableViewCell
    
        let letter = sectionHeaders.object(at: indexPath.section)
        let membersForLetter = membersDictionary[letter as! String]
        let member = membersForLetter?[indexPath.row]
        
        cell.textLabel?.text = member?.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let collection = KCSCollection.init(from: "Members", of: Member.self)
            let store = KCSAppdataStore(collection: collection, options: nil)
            
            let memberToDelete = members[indexPath.row]
            members.remove(at: indexPath.row)
            
            if let event = event {
                event.removeAttendee(entityId: memberToDelete.entityId!)
                event.save {
                    self.refresh.beginRefreshingManually()
                }
            } else {
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
            }

            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print ("\(members[indexPath.row].name)")
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MemberViewController") as! MemberViewController
        
        var index = 0
        
        for i in 0..<indexPath.section {
            index += rowCountInSectionHeaders[i]
        }
        
        index += indexPath.row
        
        vc.member = members[index]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
            
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller
            
            if let selectedMemberCell = sender as? UITableViewCell {
                let membertViewController = segue.destination as! MemberViewController
                let indexPath = tableView.indexPath(for: selectedMemberCell)!
                let selectedEvent = members[(indexPath.row)]
                membertViewController.member = selectedEvent
            }
        }
    
        func loadDataFromRefresh() {
            loadData(event: event)
        }
    
    func sortMembers() {
        
        members.sort { (a, b) -> Bool in
            return a.name < b.name
        }
        
        sectionHeaders = []
        rowCountInSectionHeaders = []
        var section = 0
        
        
        
        for letter in alphabet {
            
            section += 1
            
            let matches = members.filter({ ($0.name?.hasPrefix(letter))! })
            if !matches.isEmpty {
                membersDictionary[letter] = []
                rowCountInSectionHeaders.append(matches.count)
                for word in matches {
                    membersDictionary[letter]?.append(word)
                    sectionHeaders.add(letter)
                }
            }
        }
    }
        
    func loadData(event: Event?) {
    
        let collection = KCSCollection.init(from: "Members", of: Member.self)
        let store = KCSAppdataStore(collection: collection, options: nil)
        
        if let event = event {
            _ = store?.loadObject(withID: event.attendees, withCompletionBlock: { (members_list, error) in
                if let members_list = members_list {
                    self.members = members_list as! [Member]
                    self.sortMembers()
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
                        self.sortMembers()
                        self.tableView.reloadData()
                    }
                    
                    self.refresh.endRefreshing()
                },
                       withProgressBlock: nil
            )

            
        }
    
    }
}
