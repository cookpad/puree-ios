//
//  PURTestBufferedOutput.swift
//  Puree
//
//  Created by tomohiro-moro on 12/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

import Foundation

class PURTestBufferedOutput : PURBufferedOutput {
    var logStorage: TestLogStorage?

    override func configure(settings: [NSObject : AnyObject]!) {
        super.configure(settings)

        self.logStorage = settings["logStorage"] as? TestLogStorage
    }

    override func writeChunk(chunk: PURBufferedOutputChunk!, completion: ((Bool) -> Void)!) {
        let logs = chunk.logs as [PURLog]
        let logString = reduce(logs as [PURLog], "") { (result, log) -> String in
            let record = join("_", map(log.userInfo) { (key, value) in "\(key)=\(value)" })
            return result + "\(log.tag)-\(record)/"
        }
        self.logStorage?.addLog(logString)
        completion(true);
    }
}
