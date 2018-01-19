//
//  DataExtension.swift
//  LKQRCode
//
//  Created by LK on 18/12/17.
//  Copyright © 2018 LK. All rights reserved.
//

import Foundation
import Contacts

extension Data {
    
    var contact: CNContact? {
        do {
            let contacts = try CNContactVCardSerialization.contacts(with: self)
            let contact = contacts.first
            return contact
        } catch {
            print("[LKQRCode] Contact Error: \(error.localizedDescription)")
        }
        return nil
    }
}
