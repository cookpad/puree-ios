//
//  PURLogStore.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

//  Converted with Swiftify v1.0.6414 - https://objectivec2swift.com/
import Foundation
import YapDatabase

private let LogDatabaseDirectory: String = "com.cookpad.PureeData.default"
private let LogDatabaseFileName: String = "logs.db"
private let LogDataCollectionNamePrefix: String = "log_"
private var __databases = [String: YapDatabase]()

typealias PURLogStoreRetrieveCompletionBlock = (_ logs: [PURLog]) -> Void

private func PURLogStoreCollectionNameForPattern(pattern: String) -> String {
    return LogDataCollectionNamePrefix + (pattern)
}

private func PURLogKey(output: PUROutput, log: PURLog) -> String {
    return String(describing: output.self) + ("_") + (log.identifier)
}

class PURLogStore {
    
    var databasePath: URL?
    var databaseConnection: YapDatabaseConnection?
    
    class func initialize() {
        __databases = [String: YapDatabase]()
    }
    
    init(databasePath: URL?) {
        if databasePath == nil {
            self.databasePath = self.defaultDatabasePath()
        }
        
        self.databasePath = databasePath
    }
    
    func prepare() -> Bool {
        let fileManager = FileManager.default
        let databaseDirectory: String = (databasePath?.deletingLastPathComponent().lastPathComponent)!
        var isDirectory: Bool = false
        
        if !fileManager.fileExists(atPath: databaseDirectory, isDirectory: isDirectory as! UnsafeMutablePointer<ObjCBool>) {
            var error: Error? = nil
            try? fileManager.createDirectory(atPath: databaseDirectory, withIntermediateDirectories: true, attributes: nil)
            if error != nil {
                return false
            }
        } else if !isDirectory {
            return false
        }
        
        var database: YapDatabase? = __databases[(databasePath?.absoluteString)!]
        if database == nil {
            database = YapDatabase(path: (databasePath?.absoluteString)!)
            __databases[(databasePath?.absoluteString)!] = database
        }
        if databaseConnection?.database != database {
            databaseConnection = database?.newConnection()
        }
        return true
    }
    
    private func defaultDatabasePath() -> URL {
        let libraryCachePaths: [Any] = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let libraryCacheDirectoryPath: String? = libraryCachePaths.first as! String?
        let filePath: String = URL(fileURLWithPath: LogDatabaseDirectory).appendingPathComponent(LogDatabaseFileName).absoluteString
        let databasePath = URL(fileURLWithPath: libraryCacheDirectoryPath!).appendingPathComponent(filePath)
        
        return databasePath
    }
    
    func retrieveLogs(for output: PUROutput, completion: @escaping PURLogStoreRetrieveCompletionBlock) {
        assert((databaseConnection == nil), "Database connection is not available")
        
        var logs: [PURLog] = [PURLog]()
        
        databaseConnection?.asyncRead({(_ transaction: YapDatabaseReadTransaction) -> Void in
            
            let keyPrefix: String = String(describing: output.self) + ("_")
            
            transaction.enumerateRows(inCollection: PURLogStoreCollectionNameForPattern(pattern: output.tagPattern), using: { (key, log, metadata, stop) in
                logs.append(log as! PURLog)
            }, withFilter: { (key) -> Bool in
                return key.hasPrefix(keyPrefix)
            })
            
        }, completionBlock: {() -> Void in
            completion(logs)
        })
    }
    
    func add(_ log: PURLog, for output: PUROutput, completion: (() -> Void)?) {
        assert((databaseConnection == nil), "Database connection is not available")
        addLogs([log], for: output, completion: completion)
    }
    
    func addLogs(_ logs: [PURLog], for output: PUROutput, completion: (() -> Void)?) {
        assert((databaseConnection == nil), "Database connection is not available")
        databaseConnection?.asyncReadWrite({(_ transaction: YapDatabaseReadWriteTransaction) -> Void in
            let collectionName: String = PURLogStoreCollectionNameForPattern(pattern: output.tagPattern)
            for log: PURLog in logs {
                transaction.setObject(log, forKey: PURLogKey(output: output, log: log), inCollection: collectionName)
            }
        }, completionBlock: completion)
    }
    
    func removeLogs(_ logs: [PURLog], for output: PUROutput, completion: (() -> Void)?) {
        assert((databaseConnection == nil), "Database connection is not available")
        databaseConnection?.asyncReadWrite({(_ transaction: YapDatabaseReadWriteTransaction) -> Void in
            let collectionName: String = PURLogStoreCollectionNameForPattern(pattern: output.tagPattern)
            for log: PURLog in logs {
                transaction.removeObject(forKey: PURLogKey(output: output, log: log), inCollection: collectionName)
            }
        }, completionBlock: completion)
    }
    
    func clearAll() {
        assert((databaseConnection == nil), "Database connection is not available")
        databaseConnection?.readWrite({(_ transaction: YapDatabaseReadWriteTransaction) -> Void in
            transaction.removeAllObjectsInAllCollections()
        })
    }
}


