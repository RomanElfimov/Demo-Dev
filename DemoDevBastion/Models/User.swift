//
//  User.swift
//  DemoDevBastion
//
//  Created by Роман Елфимов on 20.04.2021.
//

import Foundation
import Firebase

struct User {
    
    // TODO: 1 - если надо добавить новые поля для хранения, то менять модель
    let email: String
    let name: String
    let surname: String
    let accessLevel: String
    let deviceUID: String
    let userID: String
    
//    let ref: DatabaseReference?
    
    init(email: String, name: String, surname: String, accessLevel: String, deviceUID: String, userID: String) {
        self.email = email
        self.name = name
        self.surname = surname
        self.accessLevel = accessLevel
        self.deviceUID = deviceUID
        self.userID = userID
//        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        email = snapshotValue["email"] as! String
        name = snapshotValue["name"] as! String
        surname = snapshotValue["surname"] as! String
        accessLevel = snapshotValue["accessLevel"] as! String
        deviceUID = snapshotValue["deviceUID"] as! String
        userID = snapshotValue["userID"] as! String
//        ref = snapshot.ref
    }
}
