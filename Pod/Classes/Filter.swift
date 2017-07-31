//
//  Filter.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

import Foundation

open class Filter {
    private(set) var identifier: String = ""
    private(set) var tagPattern: String?
    private(set) var logger: Logger?
    private(set) var logStore: LogStore?
    
    public init(logger: Logger, tagPattern: String?) {
        self.identifier = UUID().uuidString
        self.tagPattern = tagPattern
        self.logger = logger
    }
    
    func getLogStore() -> LogStore? {
        return logger?.logStore()
    }
    
    open func configure(_ settings: [String: Any]) {
    }
    
    func logs(withObject object: Any, tag: String, captured: String?) -> [Log] {
        if !(object is [AnyHashable: Any]) {
            return []
        }
        
        if let currentDate = logger?.currentDate() {
            return [Log(tag: tag, date: currentDate, userInfo: object as! [String : Any])]
        }
        
        return []
    }
}
