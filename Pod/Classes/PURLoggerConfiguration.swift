//
//  PURLoggerConfiguration.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

//  Converted with Swiftify v1.0.6414 - https://objectivec2swift.com/
import Foundation

class PURLoggerConfiguration {
    var logStore: PURLogStore?
    var filterSettings = [PURFilterSetting]()
    var outputSettings = [PUROutputSetting]()
    
    class func defaultConfiguration() -> PURLoggerConfiguration {
        let configuration = PURLoggerConfiguration()
        
        configuration.logStore = PURLogStore(databasePath: nil)
        configuration.filterSettings = []
        configuration.outputSettings = []
        
        return configuration
    }
}
