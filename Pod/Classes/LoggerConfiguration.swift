//
//  LoggerConfiguration.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

//  Converted with Swiftify v1.0.6414 - https://objectivec2swift.com/
import Foundation

public class LoggerConfiguration {
    var logStore: LogStore?
    public var filterSettings = [FilterSetting]()
    public var outputSettings = [OutputSetting]()
    
    public class func defaultConfiguration() -> LoggerConfiguration {
        let configuration = LoggerConfiguration()
        
        configuration.logStore = LogStore(databasePath: nil)
        configuration.filterSettings = []
        configuration.outputSettings = []
        
        return configuration
    }
}
