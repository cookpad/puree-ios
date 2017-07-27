//
//  PUROutput.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

import Foundation

class PUROutput {
    private(set) var identifier: String = ""
    private(set) var tagPattern: String = ""
    private(set) var logger: PURLogger?
    private(set) var logStore: PURLogStore?
    
    init(logger: PURLogger,
         tagPattern: String) {
        self.identifier = UUID().uuidString
        self.tagPattern = tagPattern
        self.logger = logger
    }
    
    func getLogStore() -> PURLogStore? {
        if let logStore = logStore {
            return logStore
        }
        
        return nil
    }
    
    func configure(_ settings: [String: Any]) {
    }
    
    func start() {
    }
    
    func resume() {
    }
    
    func suspend() {
    }
    
    func emitLog(_ log: PURLog) {
    }
}
