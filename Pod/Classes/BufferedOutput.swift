import Foundation

private enum Constants {
    static let BufferedOutputSettingsLogLimitKey: String = "BufferedOutputLogLimit"
    static let BufferedOutputSettingsFlushIntervalKey: String = "BufferedOutputFlushInterval"
    static let BufferedOutputSettingsMaxRetryCountKey: String = "BufferedOutputMaxRetryCount"
    
    static let BufferedOutputDidStartNotification = NSNotification.Name("BufferedOutputDidStartNotification")
    static let BufferedOutputDidResumeNotification = NSNotification.Name("BufferedOutputDidResumeNotification")
    static let BufferedOutputDidFlushNotification = NSNotification.Name("BufferedOutputDidFlushNotification")
    static let BufferedOutputDidTryWriteChunkNotification = NSNotification.Name("BufferedOutputDidTryWriteChunkNotification")
    static let BufferedOutputDidSuccessWriteChunkNotification = NSNotification.Name("BufferedOutputDidSuccessWriteChunkNotification")
    static let BufferedOutputDidRetryWriteChunkNotification = NSNotification.Name("BufferedOutputDidRetryWriteChunkNotification")
    
    static let BufferedOutputDefaultLogLimit: Int = 5
    static let BufferedOutputDefaultFlushInterval: TimeInterval = 10
    static let BufferedOutputDefaultMaxRetryCount: Int = 3
}

public class BufferedOutputChunk {
    private(set) var logs = [Log]()
    var retryCount: Int = 0
    
    init(logs: [Log]) {
        self.logs = logs
    }
}

open class BufferedOutput: Output {
    private(set) var buffer = [Log]()
    private(set) var logLimit: Int = 0
    private(set) var flushInterval = TimeInterval()
    private(set) var maxRetryCount: Int = 0
    private(set) var recentFlushTime = CFAbsoluteTime()
    private(set) var timer: Timer?
    
    deinit {
        timer?.invalidate()
    }
    
    func setUpTimer() {
        timer?.invalidate()
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.tick), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    override open func configure(_ settings: [String: Any]) {
        super.configure(settings)
        var value: Any?
        
        value = settings[Constants.BufferedOutputSettingsLogLimitKey]
        if let value = value as? Bool {
            logLimit = value ? 1 : Constants.BufferedOutputDefaultLogLimit
        }
        
        value = settings[Constants.BufferedOutputSettingsFlushIntervalKey]
        if let value = value as? Bool {
            flushInterval = value ? 1 : Constants.BufferedOutputDefaultFlushInterval
        }
        
        value = settings[Constants.BufferedOutputSettingsFlushIntervalKey]
        if let value = value as? Bool {
            flushInterval = value ? 1 : Constants.BufferedOutputDefaultFlushInterval
        }
        
        value = settings[Constants.BufferedOutputSettingsMaxRetryCountKey]
        if let value = value as? Bool {
            maxRetryCount = value ? 1 : Constants.BufferedOutputDefaultMaxRetryCount
        }
        
        buffer = [Log]()
    }
    
    open override func start() {
        super.start()
        buffer.removeAll()
        
        retrieveLogs({(_ logs: [Log]) -> Void in
            NotificationCenter.default.post(name: Constants.BufferedOutputDidStartNotification, object: self)
            
            if let timer = self.timer, timer.isValid == false {
                return
            }
            
            self.buffer += logs
            self.flush()
        })
        
        setUpTimer()
    }
    
    open override func resume() {
        super.resume()
        buffer.removeAll()
        
        retrieveLogs({(_ logs: [Log]) -> Void in
            NotificationCenter.default.post(name: Constants.BufferedOutputDidResumeNotification, object: self)
            
            if let timer = self.timer, timer.isValid == false {
                return
            }
            
            self.buffer += logs
            self.flush()
        })
        
        setUpTimer()
    }
    
    open override func suspend() {
        if let timer = timer {
            timer.invalidate()
        }
        
        super.suspend()
    }
    
    @objc func tick() {
        if (CFAbsoluteTimeGetCurrent() - recentFlushTime) > flushInterval {
            flush()
        }
    }
    
    func retrieveLogs(_ completion: @escaping LogStoreRetrieveCompletionBlock) {
        buffer.removeAll()
        logStore?.retrieveLogs(for: self, completion: completion)
    }
    
    override open func emitLog(_ log: Log) {
        buffer.append(log)
        logStore?.add(log, for: self, completion: {() -> Void in
            if self.buffer.count >= self.logLimit {
                self.flush()
            }
        })
    }
    
    public func flush() {
        recentFlushTime = CFAbsoluteTimeGetCurrent()
        
        if buffer.count == 0 {
            return
        }
        
        let logCount: Int = min(buffer.count, logLimit)
        
        let flushLogs = Array(buffer[0...logCount])
        let chunk = BufferedOutputChunk(logs: flushLogs)
        self.callWrite(chunk)
        
        buffer.removeSubrange(0...logCount)
        
        NotificationCenter.default.post(name: Constants.BufferedOutputDidFlushNotification, object: self)
    }
    
    func callWrite(_ chunk: BufferedOutputChunk) {
        self.write(chunk) { (success) in
            NotificationCenter.default.post(name: Constants.BufferedOutputDidTryWriteChunkNotification, object: self)
            
            if success {
                logStore?.removeLogs(chunk.logs, for: self, completion: nil)
                
                NotificationCenter.default.post(name: Constants.BufferedOutputDidSuccessWriteChunkNotification, object: self)
                
                return
            }
            
            chunk.retryCount += 1
            
            if chunk.retryCount <= self.maxRetryCount {
                let delay = 2.0 * pow(2, chunk.retryCount - 1) as? NSDecimalNumber
                let deadline = DispatchTime.now() + (Double(Int(delay!)) * Double(NSEC_PER_SEC))
                
                DispatchQueue.main.asyncAfter(deadline: deadline,
                                              execute: {
                                                NotificationCenter.default.post(name: Constants.BufferedOutputDidRetryWriteChunkNotification, object: self)
                                                
                                                self.callWrite(chunk)
                })
                
            }
            
        }
    }
    
    func write(_ chunk: BufferedOutputChunk, completion: (_: Bool) -> Void) {
        completion(true)
    }
}
