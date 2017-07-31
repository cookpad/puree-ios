//
//  Log.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

import Foundation

public class Log: NSCoding {
    private(set) var identifier: String = ""
    private(set) var tag: String = ""
    private(set) var date: Date?
    private(set) var userInfo = [String: Any]()
    
    init(tag: String, date: Date, userInfo: [String: Any]) {
        self.identifier = UUID().uuidString
        self.tag = tag
        self.date = date
        self.userInfo = userInfo
    }
    
    required public init?(coder aDecoder: NSCoder) {
        identifier = aDecoder.decodeObject(forKey: "identifier") as! String
        tag = aDecoder.decodeObject(forKey: "tag") as? String ?? ""
        date = aDecoder.decodeObject(forKey: "date") as? Date ?? Date()
        userInfo = aDecoder.decodeObject(forKey: "userInfo") as? [String: Any] ?? [String: Any]()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(tag, forKey: "tag")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(userInfo, forKey: "userInfo")
    }
}
