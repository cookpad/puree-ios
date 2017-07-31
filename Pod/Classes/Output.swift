//
//  Output.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

import Foundation

open class Output {
    private(set) var identifier: String = ""
    private(set) var tagPattern: String = ""
    private(set) var logger: Logger?
    private(set) var logStore: LogStore?
    
    public init(logger: Logger, tagPattern: String) {
        self.identifier = UUID().uuidString
        self.tagPattern = tagPattern
        self.logger = logger
    }
    
    open func getLogStore() -> LogStore? {
        if let logStore = logStore {
            return logStore
        }
        
        return nil
    }
    
    open func configure(_ settings: [String: Any]) {
    }
    
    open func start() {
    }
    
    open func resume() {
    }
    
    open func suspend() {
    }
    
    open func emitLog(_ log: Log) {
    }
}
