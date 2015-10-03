//
//  PURTestOutput.swift
//  Puree
//
//  Created by tomohiro-moro on 12/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

import Foundation
import Puree

class PURTestOutput : PUROutput {
    var logStorage: TestLogStorage!

    override func configure(settings: [NSObject : AnyObject]?) {
        super.configure(settings)

        self.logStorage = settings!["logStorage"] as! TestLogStorage
    }

    override func emitLog(log: PURLog) {
        let userInfo = log.userInfo as! [String: String]
        let record = userInfo.keys.sort().map { "\($0)=\(log.userInfo[$0]!)" }.joinWithSeparator("_")
        self.logStorage.addLog("\(log.tag)-\(record)")
    }
}
