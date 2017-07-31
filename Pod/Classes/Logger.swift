//
//  Logger.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

import Foundation

public class Logger {
    
    var configuration: LoggerConfiguration?
    var defaultFilter: Filter?
    var filters = [String: Filter]()
    var filterReactionTagPatterns = [String: String]()
    var outputs = [String: Output]()
    var outputReactionTagPatterns = [String: String]()
    
    public class func matchesTag(_ tag: String, pattern: String) -> TagCheckingResult {
        
        if (tag == pattern) {
            return TagCheckingResult.success()
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
                
                let tagElement = tagElements[idx]
                
                if !(tagElement == val) {
                    matched = false
                    break
                }
            }
            
            if matched {
                let location: Int = patternElements.count - 1
                let capturedLength: Int = tagElements.count - location
                var capturedString: String = ""
                
                if capturedLength > 0 {
                    capturedString = tagElements[Range(uncheckedBounds: (location, capturedLength))].joined(separator: elementsSeparator)
                }
                
                return TagCheckingResult.successResult(withCapturedString: capturedString)
            }
            
        } else if (lastPatternElement == wildcard) {
            if tagElements.count == patternElements.count {
                var matched: Bool = true
                
                for (idx, val) in patternElements.enumerated() {
                    let tagElement: String = tagElements[idx]
                    if !(tagElement == val) {
                        matched = false
                        break
                    }
                }
                
                if matched {
                    return TagCheckingResult.successResult(withCapturedString: tagElements.last)
                }
            }
        }
        
        return TagCheckingResult.failure()
    }
    
    public init(configuration: LoggerConfiguration) {
        self.configuration = configuration
        configure()
        startPlugins()
    }
    
    deinit {
        shutdown()
    }
    
    func logStore() -> LogStore? {
        return configuration?.logStore
    }
    
    func currentDate() -> Date? {
        return Date()
    }
    
    public func configure() {
        let logStore: LogStore? = configuration?.logStore
        let _ = logStore?.prepare()
        
        configureFilterPlugins()
        configureOutputPlugins()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func configureFilterPlugins() {
        defaultFilter = Filter(logger: self, tagPattern: nil)
        
        var filters = [String: Filter]()
        var filterReactionTagPatterns = [String: String]()
        
        if let configuration = configuration {
            for setting in configuration.filterSettings {
                
                let filter = Filter(logger: self, tagPattern: setting.tagPattern)
                
                if let pluginSettings = setting.settings {
                    filter.configure(pluginSettings)
                    filters[filter.identifier] = filter
                    filterReactionTagPatterns[filter.identifier] = setting.tagPattern
                }
            }
            
            self.filters = filters
            self.filterReactionTagPatterns = filterReactionTagPatterns
        }
    }
    
    func configureOutputPlugins() {
        var outputs = [String: Output]()
        var outputReactionTagPatterns = [String: String]()
        
        if let configuration = configuration {
            for setting in configuration.outputSettings {
                
                let output = Output(logger: self, tagPattern: setting.tagPattern)
                
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
        for (_, output) in outputs.enumerated() {
            output.value.start()
        }
    }
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        for (_, output) in outputs.enumerated() {
            output.value.suspend()
        }
    }
    
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        for (_, output) in outputs.enumerated() {
            output.value.resume()
        }
    }
    
    func filteredLogs(withObject object: Any, tag: String) -> [Log] {
        var logs = [Log]()
        
        for (key, _) in filterReactionTagPatterns {
            
            let pattern = filterReactionTagPatterns[key]
            let result: TagCheckingResult? = Logger.matchesTag(tag, pattern: pattern!)
            
            let filter: Filter? = filters[key]
            if let filteredLogs = filter?.logs(withObject: object, tag: tag, captured: (result?.capturedString)!) {
                for log in filteredLogs {
                    logs.append(log)
                }
            }
        }
        
        if logs.count == 0 {
            return defaultFilter!.logs(withObject: object, tag: tag, captured: nil)
        }
        
        return logs
    }
    
    public func post(_ object: Any, tag sourceTag: String) {
        for log in filteredLogs(withObject: object, tag: sourceTag) {
            for (_, value) in outputReactionTagPatterns.enumerated() {
                if Logger.matchesTag(log.tag, pattern: value.value).isMatched {
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
