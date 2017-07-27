//
//  PURLogger.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

import Foundation

class PURLogger {
    
    var configuration: PURLoggerConfiguration?
    var defaultFilter: PURFilter?
    var filters = [String: PURFilter]()
    var filterReactionTagPatterns = [String: String]()
    var outputs = [String: PUROutput]()
    var outputReactionTagPatterns = [String: String]()
    
    class func matchesTag(_ tag: String, pattern: String) -> PURTagCheckingResult {
        
        if (tag == pattern) {
            return PURTagCheckingResult.success()
        }
        
        let elementsSeparator: String = "."
        let wildcard: String = "*"
        let allWildcard: String = "**"
        let patternElements: [String] = pattern.components(separatedBy: elementsSeparator)
        let tagElements: [String] = tag.components(separatedBy: elementsSeparator)
        let lastPatternElement = patternElements.last
        
        if (lastPatternElement == allWildcard) {
            var matched: Bool = true
            
            for (idx, val) in patternElements.enumerated() {
                
                var tagElement = tagElements[idx]
                
                if !(tagElement == val) {
                    matched = false
                    break
                }
            }
            
            if matched {
                var location: Int = patternElements.count - 1
                var capturedLength: Int = tagElements.count - location
                var capturedString: String = ""
                
                if capturedLength > 0 {
                    capturedString = tagElements[Range(uncheckedBounds: (location, capturedLength))].joined(separator: elementsSeparator)
                }
                
                return PURTagCheckingResult.successResult(withCapturedString: capturedString)
            }
            
        } else if (lastPatternElement == wildcard) {
            if tagElements.count == patternElements.count {
                var matched: Bool = true
                
                for (idx, val) in patternElements.enumerated() {
                    var tagElement: String = tagElements[idx]
                    if !(tagElement == val) {
                        matched = false
                        break
                    }
                }
                
                if matched {
                    return PURTagCheckingResult.successResult(withCapturedString: tagElements.last)
                }
            }
        }
        
        return PURTagCheckingResult.failure()
    }
    
    init(configuration: PURLoggerConfiguration) {
        self.configuration = configuration
        configure()
        startPlugins()
    }
    
    deinit {
        shutdown()
    }
    
    func logStore() -> PURLogStore? {
        return configuration?.logStore
    }
    
    func currentDate() -> Date? {
        return Date()
    }
    
    func configure() {
        let logStore: PURLogStore? = configuration?.logStore
        logStore?.prepare()
        
        configureFilterPlugins()
        configureOutputPlugins()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func configureFilterPlugins() {
        defaultFilter = PURFilter(logger: self, tagPattern: nil)
        
        var filters = [String: PURFilter]()
        var filterReactionTagPatterns = [String: String]()
        
        if let configuration = configuration {
            for setting in configuration.filterSettings {
                
                let filter = PURFilter(logger: self, tagPattern: setting.tagPattern)
                
                if let pluginSettings = setting.settings {
                    filter.configure(settings: pluginSettings)
                    filters[filter.identifier] = filter
                    filterReactionTagPatterns[filter.identifier] = setting.tagPattern
                }
            }
            
            self.filters = filters
            self.filterReactionTagPatterns = filterReactionTagPatterns
        }
    }
    
    func configureOutputPlugins() {
        var outputs = [String: PUROutput]()
        var outputReactionTagPatterns = [String: String]()
        
        if let configuration = configuration {
            for setting in configuration.outputSettings {
                
                let output = PUROutput(logger: self, tagPattern: setting.tagPattern)
                
                if let pluginSettings = setting.settings {
                    output.configure(pluginSettings)
                    outputs[output.identifier] = output
                    outputReactionTagPatterns[output.identifier] = setting.tagPattern
                }
            }
            
            self.outputs = outputs
            self.outputReactionTagPatterns = outputReactionTagPatterns
        }
    }
    
    func startPlugins() {
        for (id, output) in outputs.enumerated() {
            output.value.start()
        }
    }
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        for (id, output) in outputs.enumerated() {
            output.value.suspend()
        }
    }
    
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        for (id, output) in outputs.enumerated() {
            output.value.resume()
        }
    }
    
    func filteredLogs(withObject object: Any, tag: String) -> [PURLog] {
        var logs = [PURLog]()
        
        for (key, value) in filterReactionTagPatterns {
            
            let pattern = filterReactionTagPatterns[key]
            let result: PURTagCheckingResult? = PURLogger.matchesTag(tag, pattern: pattern!)
            
            let filter: PURFilter? = filters[key]
            if let filteredLogs = filter?.logs(object: object, tag: tag, captured: result?.capturedString) {
                for log in filteredLogs {
                    logs.append(log)
                }
            }
        }
        
        if logs.count == 0 {
            return defaultFilter!.logs(object: object, tag: tag, captured: nil)
        }
        
        return logs
    }
    
    func postLog(_ object: Any, tag sourceTag: String) {
        for log in filteredLogs(withObject: object, tag: sourceTag) {
            for (key, value) in outputReactionTagPatterns.enumerated() {
                if PURLogger.matchesTag(log.tag, pattern: value.value).isMatched {
                    let output = self.outputs[value.key]
                    output?.emitLog(log)
                }
            }
            
        }
    }
    
    func shutdown() {
        
        filters.removeAll()
        filterReactionTagPatterns.removeAll()
        
        for output in outputs {
            output.value.suspend()
        }
        
        outputs.removeAll()
        outputReactionTagPatterns.removeAll()
        
        NotificationCenter.default.removeObserver(self)
    }
}
