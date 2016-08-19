//
//  Member.swift
//  check-in
//
//  Created by Matt Garnett on 8/14/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import Foundation

class Member : NSObject {
    
    /* -------------------------------------------------------- */
    
    private(set) var entityId: String? //Kinvey entity _id
    private(set) var name: String?
    private(set) var email: String?
    private(set) var id : String?
    private(set) var events: [String]
    private(set) var groupIdentifier: String?
    private(set) var metadata: KCSMetadata? //Kinvey metadata, optional
    
    /* -------------------------------------------------------- */
    
    // Set-ers
    
    func setEntityId(e: String) { entityId = e }
    func setName(n: String) { name = n }
    func setEmail(e: String) { email = e }
    func setId(i: String) { id = i }
    func setEvents(e: [String]) { events = e }
    func setGroupIdentifier(g: String) { groupIdentifier = g }
    func setMetadata(m: KCSMetadata) { metadata = m }
    func setAll(_entityId: String, _name: String, _email: String, _id: String, _events: [String], _groupIdentifer: String, _metadata: KCSMetadata) {
        entityId = _entityId
        name = _name
        email = _email
        id = _id
        events = _events
        groupIdentifier = _groupIdentifer
        metadata = _metadata
    }
    
    /* -------------------------------------------------------- */
    
    override init() {
        events = []
        super.init()
    }
    
    func save(completion: () -> Void) {
        let collection = KCSCollection.init(from: "Members", of: Member.self)
        let store = KCSAppdataStore(collection: collection, options: nil)
        
        store!.save(
            self,
            withCompletionBlock: { (KCSCompletionBlock) -> Void in
                if KCSCompletionBlock.1 != nil {
                    //save failed
                    NSLog("Save failed, with error: %@", KCSCompletionBlock.1!)
                    
                } else {
                    //save was successful
                    completion()
                    NSLog("Successfully saved member (id='%@').", (KCSCompletionBlock.0?[0] as! NSObject).kinveyObjectId())
                }
            },
            withProgressBlock: nil)
    }
    
    func loadFromID(id: String, groupID: String, completion: (success: Bool) -> Void) {
        
        let collection = KCSCollection.init(from: "Members", of: Member.self)
        let store = KCSAppdataStore(collection: collection, options: nil)
        
        var success = false
        
        
        let query = KCSQuery(onField: "groupIdentifier", withExactMatchForValue: groupID)
        
        _ = store?.query(withQuery:
            query, withCompletionBlock: { (member_list, error) -> Void in
                if let member_list = member_list as? [Member]{
                    for m in member_list {
                        if m.id == id {
                            self.entityId = m.entityId
                            self.name = m.name
                            self.email = m.email
                            self.id = m.id
                            self.events = m.events
                            self.groupIdentifier = m.groupIdentifier
                            self.metadata = m.metadata
                            success = true
                        }
                    }
                } else {
                    // Couldn't find the id in the database, begin configuring new member
                    self.id = id
                }
                
                completion(success: success)
            },
                   withProgressBlock: nil
        )

    }
    
    func addEvent(e: Event) -> Bool {
        if (events.index(of: e.entityId!)) != nil {
            return false
        } else {
            events.append(e.entityId!)
            return true
        }
    }
    
    func removeEvent(entityId: String) {
        if let i = events.index(of: entityId) {
            events.remove(at: i)
        }
    }
    
    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
        return [
            "entityId" : KCSEntityKeyId, //the required _id field
            "name" : "name",
            "email": "email",
            "id" : "id",
            "events" : "events",
            "groupIdentifier" : "groupIdentifier",
            "metadata" : KCSEntityKeyMetadata //optional _metadata field
        ]
    }
}
