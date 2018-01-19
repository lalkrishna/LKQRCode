//
//  Models.swift
//  LKQRCode
//
//  Created by LK on 17/01/18.
//  Copyright © 2018 LK. All rights reserved.
//

import Foundation

public struct WiFi {
    
    public enum Encription: String {
        case none = "nopass"
        case wpa = "WPA"
        case wep = "WEP"
    }
    
    public var encription: Encription
    public var networkName: String
    public var password: String?
    public var hidden: Bool = false
    
    public var desciption: String {
        guard encription != .none else {
            return "WIFI:T:\(encription.rawValue);S:\(networkName);P:;H:\(hidden.description);"
        }
        return "WIFI:T:\(encription.rawValue);S:\(networkName);P:\(password ?? "");H:\(hidden.description);"
    }
    
    public init(encription: Encription, networkName: String, password: String?, hidden: Bool) {
        self.encription = encription
        self.networkName = networkName
        self.password = password
        self.hidden = hidden
    }
    

}



