//
//  Validator.swift
//  check-in
//
//  Created by Matt Garnett on 8/15/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import Foundation

class Validator {
    
    func isValidEmail (email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func isValidPassword (password: String) -> Bool {
        return password.characters.count > 7
    }
   
    func isValidUsername(username: String) -> Bool {
        let emailRegex = "^[a-zA-Z]+$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: username) && username.characters.count > 2

    }
}
