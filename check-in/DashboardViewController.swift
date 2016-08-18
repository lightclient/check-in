//
//  DashboardViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/16/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var type : String?
    var events = [Event]()
    @IBOutlet weak var listView: UITableView!
    
    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.23, green:0.48, blue:0.84, alpha:1.0)//getRandomColor()
        listView.dataSource = self
        listView.delegate = self
        listView.backgroundColor = UIColor(red:0.23, green:0.38, blue:0.45, alpha:1.0)
        
        if let type = type {
           loadData(viewType: type)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Best Events"
        } else if section == 1 {
            return "Worst Events"
        }
        
        return ""
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myLabel = UILabel()
        let cell = DashboardCell()
        myLabel.frame = CGRect(x: 15, y: cell.frame.height / 2, width: 320, height: 20)
        myLabel.font = UIFont(name: "Futura-bold", size: 18)
        myLabel.text = self.tableView(listView, titleForHeaderInSection: section)
        myLabel.textColor = .white
        let myView = UIView()
        myView.addSubview(myLabel)
        return myView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! DashboardCell
        
        if let type = type {
            if type == "events" {
                let event = events[indexPath.row]
                cell.eventText.text = event.name
                cell.locationText.text = event.location
                cell.numberOfAttendeesLabel.text = "\(event.attendees.count)"
                cell.backgroundColor = UIColor(red:0.23, green:0.38, blue:0.45, alpha:1.0)
            }
        }
        

        
        return cell
    }

    func loadData(viewType: String) {

        switch viewType {
        
        case "events":
                
                let collection = KCSCollection.init(from: "Events", of: Event.self)
                let store = KCSAppdataStore(collection: collection, options: nil)
                
                let query = KCSQuery(onField: "groupIdentifier", withExactMatchForValue: KCSUser.active().getValueForAttribute("groupIdentifier") as! String)
                
                _ = store?.query(withQuery:
                    query, withCompletionBlock: { (events_list, error) -> Void in
                        if let events_list = events_list {
                            self.events = events_list as! [Event]
                            self.listView.reloadData()
                        }
                        //self.refresh.endRefreshing()
                    },
                           withProgressBlock: nil
                )

            break
            
        case "members":
            break
            
        default:
            break
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
