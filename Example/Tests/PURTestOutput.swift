//
//  PURTestOutput.swift
//  Puree
//
//  Created by tomohiro-moro on 12/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

import Foundation

class PURTestOutput : PUROutput {
    var logStorage: TestLogStorage?

    override func configure(settings: [NSObject : AnyObject]!) {
        super.configure(settings)

        self.logStorage = settings["logStorage"] as? TestLogStorage
    }

    override func emitLog(log: PURLog!) {
        let record = map(log.userInfo) { (key, value) in "\(key)=\(value)" }.joinWithSeparator("_")
        self.logStorage?.addLog("\(log.tag)-\(record)")
    }
}
