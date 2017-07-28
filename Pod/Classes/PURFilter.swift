//
//  PURFilter.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

import Foundation

class PURFilter {
    private(set) var identifier: String = ""
    private(set) var tagPattern: String?
    private(set) var logger: PURLogger?
    private(set) var logStore: PURLogStore?
    
    init(logger: PURLogger, tagPattern: String?) {
        self.identifier = UUID().uuidString
        self.tagPattern = tagPattern
        self.logger = logger
    }
    
    func getLogStore() -> PURLogStore? {
        return logger?.logStore()
    }
    
    func configure(_ settings: [String: Any]) {
    }
    
    func logs(withObject object: Any, tag: String, captured: String?) -> [PURLog] {
        if !(object is [AnyHashable: Any]) {
            return []
        }
        
        if let currentDate = logger?.currentDate() {
            return [PURLog(tag: tag, date: currentDate, userInfo: object as! [String : Any])]
        }
        
        return []
    }
}
