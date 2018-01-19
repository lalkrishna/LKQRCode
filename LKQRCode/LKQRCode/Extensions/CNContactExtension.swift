
//
//  CNContactExtension.swift
//  LKQRCode
//
//  Created by LK on 17/01/18.
//  Copyright © 2018 LK. All rights reserved.
//

import Foundation
import Contacts

extension CNContact {
    
    func vcardData() -> Data? {
        
        do {
            let data = try CNContactVCardSerialization.data(with: [self])
            return data
            
        } catch  {
            print("Error on CNContactVCardSerialization: \(error.localizedDescription)")
            return nil
        }
    }
}
